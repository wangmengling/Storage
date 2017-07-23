//
//  StorageSQLiteManager.swift
//  Storage
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation

let SQLITE_DATE = SQLITE_NULL + 1

private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)


public struct StorageSQLiteManager {
    
    public static let instanceManager:StorageSQLiteManager = {
        return StorageSQLiteManager()
    }()
    
    fileprivate var db:OpaquePointer? = nil
    // 1.定义游标指针
    fileprivate var stmt : OpaquePointer? = nil
    
    fileprivate var dbName:String = "StorageDb.db"
    
    init(dbName:String = "StorageDb.db"){
        self.openDB(dbName)
    }
}

extension StorageSQLiteManager {
    
    mutating func openDB(_ dbName:String) -> Void {
        if sqlite3_open(self.path(dbName), &db) != SQLITE_OK {
            print("SQLiteDB - failed to open DB!")
            sqlite3_close(db)
            return
        }
    }
    
    func closeDB() -> Void {
        if db != nil {
            sqlite3_close(db)
        }
    }
    
    
    func path(_ dbName:String) -> String {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return ""
        }
        let dbPath = (path as NSString).appendingPathComponent(dbName)
        print(dbPath)
        return dbPath
    }
}

extension StorageSQLiteManager {
    
    /// 执行查询操作(将查询到的结果返回到一个字典数组中)
    func count(_ querySQL : String) -> Int {
        var count = 0
        // 1.定义游标指针
        var stmt : OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, querySQL, -1, &stmt, nil) != SQLITE_OK {
            print("没有准备好查询")
            return count
        }
        // 3.查看是否有下一条语句
        if sqlite3_step(stmt) == SQLITE_ROW {
            guard let value = getColumnValue(Int32(0), type: SQLITE_INTEGER, stmt: stmt!) else {
                return count
            }
            count = value as! Int
        }
        sqlite3_finalize(stmt)
        return count
    }
}


extension StorageSQLiteManager {
    
    
    mutating func fetchArray(_ sql:String) -> [[String : AnyObject]] {
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            print("没有准备好查询")
            return []
        }
        
        // 3.查看是否有下一条语句
        var dictArray = [[String : AnyObject]]()
        while sqlite3_step(stmt) == SQLITE_ROW {
            // 有下一条语句,则将该语句转成字典,放入数组中
            dictArray.append(getRecord(stmt!))
        }
        return dictArray
    }
    
    /// 根据'游标指针'获取一条数据
    func getRecord(_ stmt : OpaquePointer) -> [String : AnyObject] {
        // 1.获取字段个数
        let count = sqlite3_column_count(stmt)
        var dict = [String : AnyObject]()
        for i in 0..<count {
            // 2.取出字典对应的key
            let cKey = sqlite3_column_name(stmt, i)
            guard let cKeys = cKey else {
                continue
            }
            guard let key = String(cString: cKeys, encoding: String.Encoding.utf8) else {
                continue
            }
            // 3.获取字段类型
            let type = self.getColumnType(i, stmt:stmt)
            
            // 4.取出字典对应的value
            guard let value = getColumnValue(i, type:type, stmt:stmt) else{
                dict[key] = nil
                continue
            }
            // 5.将键值放入字典中
            dict[key] = value
        }
        return dict
    }
}

extension StorageSQLiteManager {
    
    //执行查询操作
    func execSQL(_ sqlString : String) -> Bool {
        var error:UnsafeMutablePointer<CChar>? = nil
        if sqlite3_exec(db, sqlString.cString(using: String.Encoding.utf8)!, nil , nil, &error) != SQLITE_OK{
            return false
        }
        return true
    }
    
    //执行更新操作
    func execIOSQL(_ sqlString : String) -> (Bool,OpaquePointer?) {
        var stmt : OpaquePointer? = nil
        var error:UnsafeMutablePointer<CChar>? = nil
        if sqlite3_exec(db, sqlString.cString(using: String.Encoding.utf8)!, nil, &stmt, &error) != SQLITE_OK{
            return (false,stmt)
        }
        return (true,stmt)
    }
}

// MARK: - column
extension StorageSQLiteManager {
    
    // Get column
    fileprivate func getColumn(stmt:OpaquePointer) -> [String] {
        let count = sqlite3_column_count(stmt)
        var columnArray = [String]()
        for i in 0..<count {
            // 2.取出字典对应的key
            let cKey = sqlite3_column_name(stmt, i)
            guard let cKeys = cKey else {
                continue
            }
            guard let key = String(cString: cKeys, encoding: String.Encoding.utf8) else {
                continue
            }
            columnArray.append(key)
        }
        return columnArray
    }
    
    // Get column type
    fileprivate func getColumnType(_ index:CInt, stmt:OpaquePointer)->CInt {
        var type:CInt = 0
        // Column types - http://www.sqlite.org/datatype3.html (section 2.2 table column 1)
        let blobTypes = ["BINARY", "BLOB", "VARBINARY"]
        let charTypes = ["CHAR", "CHARACTER", "CLOB", "NATIONAL VARYING CHARACTER", "NATIVE CHARACTER", "NCHAR", "NVARCHAR", "TEXT", "VARCHAR", "VARIANT", "VARYING CHARACTER"]
        //        let dateTypes = ["DATE", "DATETIME", "TIME", "TIMESTAMP"]
        let intTypes  = ["BIGINT", "BIT", "BOOL", "BOOLEAN", "INT", "INT2", "INT8", "INTEGER", "MEDIUMINT", "SMALLINT", "TINYINT"]
        let nullTypes = ["NULL"]
        let realTypes = ["DECIMAL", "DOUBLE", "DOUBLE PRECISION", "FLOAT", "NUMERIC", "REAL"]
        // Determine type of column - http://www.sqlite.org/c3ref/c_blob.html
        let buf = sqlite3_column_decltype(stmt, index)
        //        NSLog("SQLiteDB - Got column type: \(buf)")
        if buf != nil {
            
            var tmp = String(cString: buf!).uppercased()
            // Remove brackets
            
            let pos = tmp.positionOf("(")
            if pos > 0 {
                tmp = tmp.subString(0, length:pos)
            }
            
            if intTypes.contains(tmp) {
                return SQLITE_INTEGER
            }
            if realTypes.contains(tmp) {
                return SQLITE_FLOAT
            }
            if charTypes.contains(tmp) {
                return SQLITE_TEXT
            }
            if blobTypes.contains(tmp) {
                return SQLITE_BLOB
            }
            if nullTypes.contains(tmp) {
                return SQLITE_NULL
            }
            //            if dateTypes.contains(tmp) {
            //                return SQLITE_DATE
            //            }
            return SQLITE_TEXT
        } else {
            // For expressions and sub-queries
            type = sqlite3_column_type(stmt, index)
        }
        return type
    }
    
    
    // Get column value
    fileprivate func getColumnValue(_ index:CInt, type:CInt, stmt:OpaquePointer)->AnyObject? {
        // Integer
        if type == SQLITE_INTEGER {
            let val = sqlite3_column_int(stmt, index)
            return Int(val) as AnyObject?
        }
        // Float
        if type == SQLITE_FLOAT {
            let val = sqlite3_column_double(stmt, index)
            return Double(val) as AnyObject?
        }
        // Text - handled by default handler at end
        // Blob
        if type == SQLITE_BLOB {
            let data = sqlite3_column_blob(stmt, index)
            let size = sqlite3_column_bytes(stmt, index)
            let val = Data(bytes: data!, count: Int(size))
            return val as AnyObject?
        }
        // Null
        if type == SQLITE_NULL {
            return nil
        }
        // If nothing works, return a string representation
        guard let buf = UnsafePointer(sqlite3_column_text(stmt, index)) else {
            return nil
        }
        let val = String(cString: buf)
        return val as AnyObject?
    }
}

extension StorageSQLiteManager {
    //执行sql之前检查sql
    fileprivate func prepare(_ sql:String, params:[AnyObject]?) -> OpaquePointer? {
        var stmt:OpaquePointer? = nil
        let cSql = sql.cString(using: String.Encoding.utf8)
        // Prepare
        let result = sqlite3_prepare_v2(self.db, cSql!, -1, &stmt, nil)
        if result != SQLITE_OK {
            sqlite3_finalize(stmt)
            if let error = String(validatingUTF8: sqlite3_errmsg(self.db)) {
                let msg = "SQLiteDB - failed to prepare SQL: \(sql), Error: \(error)"
                print(msg)
            }
            return nil
        }
        // Bind parameters, if any
        guard let params = params else { return stmt }
        // Validate parameters
        let cntParams = sqlite3_bind_parameter_count(stmt)
        let cnt = CInt(params.count)
        if cntParams != cnt {
            let msg = "SQLiteDB - failed to bind parameters, counts did not match. SQL: \(sql), Parameters: \(params)"
            print(msg)
            return nil
        }
        var flag:CInt = 0
        // Text & BLOB values passed to a C-API do not work correctly if they are not marked as transient.
        for ndx in 1...cnt {
            //                NSLog("Binding: \(params![ndx-1]) at Index: \(ndx)")
            // Check for data types
            let preNdx:Int = Int(ndx) - 1
            if let txt = params[preNdx] as? String {
                flag = sqlite3_bind_text(stmt, CInt(ndx), txt, -1, SQLITE_TRANSIENT)
            } else if let data = params[preNdx] as? Data {
                flag = sqlite3_bind_blob(stmt, CInt(ndx), (data as NSData).bytes, CInt(data.count), SQLITE_TRANSIENT)
                //                } else if let date = params![ndx-1] as? NSDate {
                //                    let txt = fmt.stringFromDate(date)
                //                    flag = sqlite3_bind_text(stmt, CInt(ndx), txt, -1, SQLITE_TRANSIENT)
            } else if let val = params[preNdx] as? Double {
                flag = sqlite3_bind_double(stmt, CInt(ndx), CDouble(val))
            } else if let val = params[preNdx] as? Int {
                flag = sqlite3_bind_int(stmt, CInt(ndx), CInt(val))
            } else {
                flag = sqlite3_bind_null(stmt, CInt(ndx))
            }
            // Check for errors
            if flag != SQLITE_OK {
                sqlite3_finalize(stmt)
                if let error = String(validatingUTF8: sqlite3_errmsg(self.db)) {
                    let msg = "SQLiteDB - failed to bind for SQL: \(sql), Parameters: \(params), Index: \(ndx) Error: \(error)"
                    print(msg)
                }
                return nil
            }
        }
        return stmt
    }
}


