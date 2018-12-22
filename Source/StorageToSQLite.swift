//
//  SrorageToSQLite.swift
//  Storage
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
public enum StorageToSQLiteSorted {
    case DESC
    case ASC
}

protocol StorageToSQLiteProtocol {
//    func inserts<T>(_ object:inout T) -> Bool
}



public struct StorageToSQLite:StorageToSQLiteProtocol {
    public static let shareInstance: StorageToSQLite = StorageToSQLite()
    private let queueID = "com.maolin.StorageToSQLite.queue"
    var sqliteManager = StorageSQLiteManager.instanceManager
    var sqliteQueue: DispatchQueue
    fileprivate var tableName:String = ""
    private init() {
        sqliteQueue = DispatchQueue(label: queueID)
    }
}


// MARK: - SelectTable

extension StorageToSQLite {
    
    mutating func objectsToSQLite(_ selectSQL:String) -> [[String : AnyObject]]? {
        return sqliteManager.fetchArray(selectSQL)
    }
    
    mutating func objectToSQLite(_ selectSQL:String) -> [String : AnyObject]? {
        return sqliteManager.fetchArray(selectSQL).last
    }
}

extension StorageToSQLite {
    mutating func count<T>(_ object:T,filter:String = "") -> Int {
        var count = 0
        self.tableName = self.tableName(object)
        //关键字 来计算count
        let countSql = "SELECT COUNT(*) AS count FROM \(self.tableName) \(filter)"
        count = sqliteManager.count(countSql)
        return count
    }
}

// MARK: - Update Data To Table
extension StorageToSQLite {
    func updatePrimaryKey<T>(_ object:T) -> Bool {
        var primaryKey:String = ""
        if object is StorageProtocol {
            let storageObject:StorageProtocol = object as! StorageProtocol
            //获取主键
            primaryKey = storageObject.primaryKey()
        }else {
            return false
        }
        
        //设置值
        let objectsMirror = Mirror(reflecting: object)
        let property = objectsMirror.children
        let primaryKeyChild:[Mirror.Child] = property.filter { child -> Bool in
            return child.label == primaryKey
        }
        var filter = ""
        if let primaryKeyValue = primaryKeyChild.first?.value {
            filter = "Where \(primaryKey) = '\(primaryKeyValue)'"
        }
        
        
        var values = ""
        
        objectsMirror.children.forEach { (arg) in
            let (key, value) = arg
            guard let columnValue:String = self.proToColumnValues(type(of: value), value) ,  columnValue.count > 0 else {
                return;
            }
           values += "\(key!) = \(columnValue)"
        }
        
        if values.count > 0 {
            values = values.subString(0, length: values.count - 1)
        }
        
        //组装
        let updateSql = "UPDATE \(self.tableName(object)) SET \(values) \(filter)"
        return sqliteManager.execSQL(updateSql)
    }
    
    public func update(_ tableName:String, _ values:String, _ filters:String, _ sorted:String, _ limit:String) -> Bool {
        let updateSql = "UPDATE \(tableName) SET \(values) \(filters) \(sorted) \(limit)"
        return sqliteManager.execSQL(updateSql)
    }
    
    
}


// MARK: - Delete Object
extension StorageToSQLite {
    
    func deleteWhere(_ tableName:String, _ filter:String, _ sorted:String = "", _ limit:String = "") -> Bool {
        let deleteSQL = "DELETE  FROM \(tableName) \(filter) \(sorted) \(limit)"
        return sqliteManager.execSQL(deleteSQL)
    }
    
    func delete<T>(_ object:T) -> Bool {
        var primaryKey:String = ""
        if object is StorageProtocol {
            let storageObject:StorageProtocol = object as! StorageProtocol
            //获取主键
            primaryKey = storageObject.primaryKey()
        }else {
            return false
        }
        //设置值
        let objectsMirror = Mirror(reflecting: object)
        let property = objectsMirror.children
        let primaryKeyChild:[Mirror.Child] = property.filter { child -> Bool in
            return child.label == primaryKey
        }
        guard let primaryKeyValue = primaryKeyChild.first?.value else {
            return false
        }
        let filter = "\(primaryKey) = '\(primaryKeyValue)'"
        return self.delete(object, filter)
    }
    
    private func delete<T>(_ object:T,_ filter:String) -> Bool {
        return self.deleteWhere(self.tableName(object), filter)
    }
    
    func deleteAll<T>(_ type:T.Type) -> Bool {
        let deleteSQL = "DELETE  FROM \(String(describing: type));"
        return sqliteManager.execSQL(deleteSQL)
    }
}

// MARK: - Insert
extension StorageToSQLite {
    
    // insert
     func insertOptional<T>(_ object:T) -> Bool {
        let mirror = Mirror(reflecting: object)
        if String(describing: mirror.subjectType).contains("Optional<") {
            var bool:Bool = false
            mirror.children.forEach { (arg) in
                bool = insert(arg.value)
            }
            return bool
        }else {
            return insert(object)
        }
    }
    
    func insert<T>(_ object:T?) -> Bool {
        guard let object = object else { return false }
        return insert(object)
    }
    
    func insert<T>(_ object:T) -> Bool {
        var columns = ""
        var values = ""
        let mirror:Mirror = Mirror(reflecting: object)
        
        mirror.children.forEach { (arg) in
            let (key, value) = arg
            guard let columnValue:String = self.proToColumnValues(type(of: value), value) ,  columnValue.count > 0 else {
                return;
            }
            columns += "\(key!),"
            values += columnValue
        }
        
        if mirror.children.count > 0 {
            columns = columns.subString(0, length: columns.count - 1)
            values = values.subString(0, length: values.count - 1)
        }
        
        let insertSQL = "INSERT INTO \(String(describing: mirror.subjectType)) (\(columns))  VALUES (\(values));"
        
        return sqliteManager.execSQL(insertSQL)
    }
    
    func insert<T>(_ object:T, _ block: @escaping (Bool) -> Void) {
        sqliteQueue.async {
            let insertResult = self.insert(object)
            DispatchQueue.main.async(execute: {
                block(insertResult)
            })
        }
    }
}


// MARK: - T property to Table Column
extension StorageToSQLite {
    
    func proToColumnValues<T>(_ fieldType:Any.Type, _ value:T? )  -> String? {
        guard let value = value else { return "" }
        let type = self.optionalTypeToType(fieldType)
        switch type {
        case is Int.Type:
            guard let v = value as? Int else {
                return ""
            }
            return "\(v),"
        case is Int8.Type:
            guard let v = value as? Int8 else {
                return ""
            }
            return "\(v),"
        case is Int16.Type:
            guard let v = value as? Int16 else {
                return ""
            }
            return "\(v),"
        case is Int32.Type:
            guard let v = value as? Int32 else {
                return ""
            }
            return "\(v),"
        case is Double.Type:
            guard let v = value as? Double else {
                return ""
            }
            return "\(v),"
        case is Float.Type:
            guard let v = value as? Float else {
                return ""
            }
            return "\(v),"
        case is Bool.Type:
            guard let v = value as? Bool,v == true else {
                return "0,"
            }
            return "1,"
        case is String.Type:
            guard let v = value as? String else {
                return ""
            }
            return "'\(v)',"
        case is Array<Any>.Type:
            let data = try! JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted)
            return "'\(data)',"
        case is Dictionary<String,Any>.Type:
            let data = try! JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted)
            return "'\(data)',"
        case is Codable.Type:
            _ = self.insertOptional(value)
            return ""
        default:
            return ""
        }
    }
    
    func proToColumnValues(_ value:Any?) -> String?{
        guard let x:Any = value else {
            return ""
        }
        
        if (x as AnyObject).debugDescription == "Optional(nil)" {
            return ""
        }
        return self.proToColumnValues(x)
    }
    
    /**
     Optional To Value
     
     - parameter value: 属性值
     
     - returns: column values
     */
    func proToColumnValues(_ value:Any) -> String?{
        
        let m =  Mirror(reflecting: value)
        
        if m.subjectType == Optional<Int>.self{
            return "\(value as! Int),"
        } else if m.subjectType == Optional<Double>.self{
            return "\(value as! Double),"
        } else if m.subjectType == Optional<Float>.self{
            return "\(value as! Float),"
        } else if m.subjectType == Optional<String>.self{
            return "'\(value as! String)',"
        }else if m.subjectType == Optional<Bool>.self{
            return "'\(value as! String)',"
        } else if m.subjectType == String.self {
            return "'\(value)',"
        } else {
            return "\(value),"
        }
    }
}



// MARK: - Table
extension StorageToSQLite {
    /**
     check table is exist
     
     - parameter object: E object
     
     - returns: Bool
     */
    func tableIsExists<T>(_ type:T.Type) -> Bool {
        let sqls = "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='\(String(describing: type))'"
        let tableNum = sqliteManager.count(sqls)
        return tableNum > 0 ? true : false
    }
    
    /**
     create table
     
     - parameter object: T object
     */
    func createTable<T>(_ object:T) -> Bool {
        let objectType = type(of: object)
        if self.tableIsExists(objectType){
            return true
        }
        let sMirror:StorageMirror = StorageMirror(reflecting: object)
        return self.createTable( String(describing: objectType),  sMirror.fieldNames, sMirror.fieldTypes)
    }
    
    
    /**
     create table
     
     - parameter tableName: String
     - parameter value: [String:Any]
     - parameter fatherTableName: String  父 table
     */
    private func createTable(_ tableName:String, _ names:[String] , _ types:[Any.Type], _ fatherTableName:String = "") -> Bool {
        var column = "storage_\(tableName)_id INTEGER PRIMARY KEY   AUTOINCREMENT,"
        
        if fatherTableName.count > 0 {
            column += "storage_\(fatherTableName)_id Int,"
        }
        
        names.enumerated().forEach { (arg) in
            let (index, pro) = arg
            let fieldType:Any.Type = types[index]
            column += self.proToColumn(pro, fieldType, tableName)
        }
        
        if column.count > 5 {
            column = column.subString(0, length: column.count - 1)
        }
        let createTabelSQL = "Create TABLE if not exists \(tableName)(\(column));"
        /// 3.执行createTableSql
        return sqliteManager.execSQL(createTabelSQL)
    }
    
    //创建子table
    private func createTable(type:Any.Type, _ fatherTableName:String = ""){
        let (typeName,optionalType) = self.typeName(type)
        if typeName.count < 1 {
            print("\(tableName)-----\(typeName) database create failed")
            return
        }
        let sMirror:StorageMirror = StorageMirror(reflecting: optionalType)
        let status = self.createTable(typeName, sMirror.fieldNames, sMirror.fieldTypes, fatherTableName)
        if !status {
            print("\(tableName)-----\(typeName) database create failed")
        }
    }
    
    /**
     SQLite Column Type
     
     - CHARACTER: CHARACTER description
     - INT:       INT description
     - FLOAT:     FLOAT description
     - DOUBLE:    DOUBLE description
     - INTEGER:   INTEGER description
     - BLOB:      BLOB description
     - NULL:      NULL description
     - TEXT:      TEXT description
     */
    enum ColumuType: String {
        case CHARACTER,INT,FLOAT,DOUBLE,INTEGER,BLOB,NULL,TEXT
    }
    
    
    private func proTypeReplace( _ fieldType:Any.Type, _ tableName:String) -> ColumuType {
        let type = self.optionalTypeToType(fieldType)
        switch type {
        case is Int.Type:
            return ColumuType.INT
        case is Double.Type:
            return ColumuType.DOUBLE
        case is Float.Type:
            return ColumuType.FLOAT
        case is String.Type:
            return ColumuType.CHARACTER
        case is Bool.Type:
            return ColumuType.INT
        case is Array<Any>.Type:
            return ColumuType.BLOB
        case is Dictionary<String,Any>.Type:
            return ColumuType.BLOB
        case is StorageProtocol.Type:
            self.createTable(type: type, tableName)
            return ColumuType.NULL
        default:
            return ColumuType.CHARACTER
        }
    }
    
    /**
     Create Table Column Structure ---- E object property To Column SQL
     
     - parameter label: object property
     - parameter value: object property value
     
     - returns: SQL
     */
    private func proToColumn(_ label:String,_ fieldType:Any.Type, _ tableName:String) -> String {
        var string = ""
        let columuType = self.proTypeReplace(fieldType,tableName)
        switch columuType {
        case ColumuType.INT:
            string += "\(label) \(ColumuType.INT.rawValue) ,"
        case ColumuType.DOUBLE:
            string += "\(label) \(ColumuType.DOUBLE.rawValue) ,"
        case ColumuType.FLOAT:
            string += "\(label) \(ColumuType.FLOAT.rawValue) ,"
        case ColumuType.CHARACTER:
            string += "\(label) \(ColumuType.CHARACTER.rawValue)(255) ,"
        case ColumuType.BLOB:
            string += "\(label) \(ColumuType.BLOB.rawValue) ,"
        default:
            return string
        }
        return string
    }
}

extension StorageToSQLite {
    public func optionalTypeToType(_ fieldType:Any.Type) -> Any.Type {
        switch fieldType {
        case is Optional<Int>.Type:
            return Int.self
        case is Optional<Int8>.Type:
            return Int8.self
        case is Optional<Int16>.Type:
            return Int16.self
        case is Optional<Int32>.Type:
            return Int32.self
        case is Optional<Double>.Type:
            return Double.self
        case is Optional<Float>.Type:
            return Float.self
        case is Optional<Bool>.Type:
            return Bool.self
        case is Optional<String>.Type:
            return String.self
        default:
            let typeName = String(describing: fieldType)
            if typeName.contains("Optional<Array<") {
                return Array<Any>.self
            }else if typeName.contains("Optional<Dictionary<") {
                return Dictionary<String,Any>.self
            }
            return fieldType
        }
    }
    
    public func tableName(_ objects:Any) -> String{
        let objectsMirror = Mirror(reflecting: objects)
        return String(describing: objectsMirror.subjectType)
    }
    
    public func typeName(_ type:Any.Type) -> (String,Any.Type){
        var optionalType = type
        var typeName = String(describing: optionalType)
        if typeName.contains("Optional<") {
            var optionalTypeName = String(describing: Optional.init(optionalType))
            if optionalTypeName.contains("Optional<") {
                optionalTypeName = optionalTypeName.subString(9, length: optionalTypeName.count-10)
            }
            if optionalTypeName.contains("Swift.Optional<") {
                optionalTypeName = optionalTypeName.subString(15, length: optionalTypeName.count-16)
            }
            let optionalClassType:AnyClass? = NSClassFromString(optionalTypeName)
            if (optionalClassType != nil) {
                optionalType = optionalClassType!
                typeName = typeName.subString(9, length: typeName.count-10)
            }else {
                let mirror = Mirror(reflecting: type)
                mirror.children.forEach({ (arg) in
                    optionalType = arg.value as! Any.Type
                })
                typeName = String(describing: optionalType)
                typeName = ""
            }
        }
        return (typeName,optionalType)
    }
}
