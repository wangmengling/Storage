//
//  SrorageToSQLite.swift
//  Storage
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
struct StorageToSQLite {
    typealias T = Codable
    public static let shareInstance:StorageToSQLite = {
        return StorageToSQLite()
    }()
    var sqliteManager = StorageSQLiteManager.instanceManager
}



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
