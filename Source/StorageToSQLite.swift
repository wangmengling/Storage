//
//  SrorageToSQLite.swift
//  Storage
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
struct StorageToSQLite {
//    typealias T = Codable
    public static let shareInstance:StorageToSQLite = {
        return StorageToSQLite()
    }()
    var sqliteManager = StorageSQLiteManager.instanceManager
    
    
    
    
//    fileprivate var objectType:T
    fileprivate var tableName:String = ""
    fileprivate var filter:String = ""
    fileprivate var sort:String = ""
    fileprivate var limit:String = ""
}

extension StorageToSQLite {
    mutating func count<T>(_ type:T,filter:String = "") -> Int {
        var count = 0
        self.tableName = String(describing: type)
        //关键字 来计算count
        let countSql = "SELECT COUNT(*) AS count FROM \(self.tableName) \(filter)"
        count = sqliteManager.count(countSql)
        return count
    }
}

// MARK: - Update Data To Table
extension StorageToSQLite {
    func update<T>(_ object:T) -> Bool {
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
        let filter = "Where \(primaryKey) = '\(primaryKeyValue)'"
        
        
        var values = ""
        if let b = AnyBidirectionalCollection(property) {
            
            b.forEach({ (child) in
                guard let columnValue:String = self.proToColumnValues(child.value) , primaryKey != child.label else  {
                    return
                }
                values += "\(child.label!) = \(columnValue)"
            })
            
            if values.characters.count > 0 {
                values = values.subString(0, length: values.characters.count - 1)
            }
        }
        //组装
        let updateSql = "UPDATE \(self.tableName(object)) SET \(values) \(filter)"
        return sqliteManager.execSQL(updateSql)
    }
}


// MARK: - Insert
extension StorageToSQLite {
    
    func insert<T>(_ object:inout T) -> Bool {
        let objectsMirror = Mirror(reflecting: object)
        let property = objectsMirror.children
        
        var columns = ""
        var values = ""
        
        let sMirror:StorageMirror = StorageMirror(reflecting: &object)
        property.forEach { (arg) in
            
            let (key, value) = arg
            var fieldTypeIndex:NSInteger = sMirror.fieldNames.index(of: key!)!
            let fieldType:Any? = sMirror.fieldTypes?.formIndex(after: &fieldTypeIndex)
            if fieldType != nil {
                
                guard let columnValue:String = self.proToColumnValues(fieldType!, value) , columnValue.characters.count > 0  else  {
                    return
                }
                columns += "\(String(describing: key)),"
                values += columnValue
            }
        }
        
        if property.count > 0 {
            columns = columns.subString(0, length: columns.characters.count - 1)
            values = values.subString(0, length: values.characters.count - 1)
        }
        
        let insertSQL = "INSERT INTO \(String(describing: objectsMirror.subjectType)) (\(columns))  VALUES (\(values));"
        
        return sqliteManager.execSQL(insertSQL)
    }
    
    fileprivate func insert(_ fieldType:[Any] ,_ value:[String:Any]) -> Bool {
        var columns = ""
        var values = ""
        
        let fieldsType = fieldType.last as? [String:Any]
        let tableName = fieldType.first as? String
        
        value.forEach { (arg) in
            let (k, v) = arg
            let fT:Any? = fieldsType?[k]
            if fT != nil {
                guard let columnValue:String = self.proToColumnValues(fT!, v ) , columnValue.characters.count > 0  else  {
                    return
                }
                columns += "\(k),"
                values += columnValue
            }
        }
        if value.count > 0 {
            columns = columns.subString(0, length: columns.characters.count - 1)
            values = values.subString(0, length: values.characters.count - 1)
        }
        if let tableName = tableName {
            let insertSQL = "INSERT INTO \(tableName) (\(columns))  VALUES (\(values));"
            return sqliteManager.execSQL(insertSQL)
        }
        return false
    }
}


// MARK: - T property to Table Column
extension StorageToSQLite {
    func proToColumnValues(_ fieldType:Any, _ value:Any )  -> String? {
        if fieldType is Int.Type{
            return "\(value as! Int),"
        }else if fieldType is Double.Type{
            return "\(value as! Double),"
        } else if fieldType is Float.Type{
            return "\(value as! Float),"
        } else if fieldType is String.Type{
            return "'\(value as! String)',"
        } else if fieldType is Bool.Type{
            let boolValue = value as! Bool
            if boolValue == true{
                return "1,"
            }
            return "0,"
        } else if fieldType is Array<Any> {
            _ = self.insert(fieldType as! [Any], value as! [String : Any])
            return ""
        }
        return "\(value as! Int),"
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
        } else if m.subjectType == ImplicitlyUnwrappedOptional<String>.self {
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
    func tableIsExists<T>(_ object:T) -> Bool {
        let objectsMirror = Mirror(reflecting: object)
        let sqls = "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='\(String(describing: objectsMirror.subjectType))'"
        let tableNum = sqliteManager.count(sqls)
        return tableNum > 0 ? true : false
    }
    
    /**
     create table
     
     - parameter object: E object
     */
    func createTable<T>(_ object:T) -> Bool {
//        let d = DataConversion<E>().fieldsType(object)
        /// 1.反射获取属性
//        let objectsMirror = Mirror(reflecting: object)
//        print(objectsMirror.children)
//        object.
        return true
    }
    
    /**
     create table
     
     - parameter tableName: String
     - parameter value: [String:Any]
     - parameter fatherTableName: String  父 table
     */
    func createTable(_ tableName:String, _ value:[String:Any], _ fatherTableName:String = "") -> Bool {
        
        
        var column = "storage_\(tableName)_id integer auto_increment ,"
        
        if fatherTableName.characters.count > 0 {
            column += "storage_\(fatherTableName)_id ,"
        }
        
        value.forEach { (arg) in
            
            let (pro, v) = arg
            column += self.proToColumn(pro, value: v)
        }
        
        if column.characters.count > 5 {
            column = column.subString(0, length: column.characters.count - 1)
        }
        let createTabelSQL = "Create TABLE if not exists \(tableName)(\(column));"
        /// 3.执行createTableSql
        return sqliteManager.execSQL(createTabelSQL)
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
    
    
    func proTypeReplace( _ value:Any,tableName:String = "") -> ColumuType {
        //        let sd = Mirror(reflecting: value)
        //        print(sd)
        if value is Int.Type{
            return ColumuType.INT
        }else if value is Double.Type{
            return ColumuType.DOUBLE
        } else if value is Float.Type{
            return ColumuType.FLOAT
        } else if value is String.Type{
            return ColumuType.CHARACTER
        } else if value is Bool.Type{
            return ColumuType.INT
        } else if value is Array<Any> {
            if self.createTable((value as AnyObject).firstObject as! String, (value as AnyObject).lastObject as! [String : Any],tableName){
                return ColumuType.INT
            }
            return ColumuType.INT
        }
        return ColumuType.CHARACTER
    }
    
    /**
     Create Table Column Structure ---- E object property To Column SQL
     
     - parameter label: object property
     - parameter value: object property value
     
     - returns: SQL
     */
    func proToColumn(_ label:String,value:Any) -> String {
        var string = ""
        let columuType = self.proTypeReplace(value)
        switch columuType {
        case ColumuType.INT:
            string += "\(label) \(ColumuType.INT.rawValue) ,"
        case ColumuType.DOUBLE:
            string += "\(label) \(ColumuType.DOUBLE.rawValue) ,"
        case ColumuType.FLOAT:
            string += "\(label) \(ColumuType.FLOAT.rawValue) ,"
        case ColumuType.CHARACTER:
            string += "\(label) \(ColumuType.CHARACTER.rawValue)(255) ,"
        default:
            return string
        }
        return string
    }
    
    /**
     type replace [eg:String To CHARACTER]
     
     - parameter value: AnyObject.Type
     
     - returns: Column Type
     */
    func typeReplace(_ value:Any?) -> ColumuType {
        guard let value = value else {
            return ColumuType.NULL
        }
        
        let m =  Mirror(reflecting: value)
        if m.subjectType ==  ImplicitlyUnwrappedOptional<Int>.self || m.subjectType == Optional<Int>.self{
            return ColumuType.INT
        } else if m.subjectType ==  ImplicitlyUnwrappedOptional<Double>.self || m.subjectType == Optional<Double>.self{
            return ColumuType.DOUBLE
        } else if m.subjectType ==  ImplicitlyUnwrappedOptional<Float>.self || m.subjectType == Optional<Float>.self{
            return ColumuType.FLOAT
        } else if m.subjectType ==  ImplicitlyUnwrappedOptional<String>.self || m.subjectType == Optional<String>.self{
            return ColumuType.CHARACTER
        }
        
        return ColumuType.NULL
    }
}

extension StorageToSQLite {
    public func tableName(_ objects:Any) -> String{
        let objectsMirror = Mirror(reflecting: objects)
        return String(describing: objectsMirror.subjectType)
    }
}

