//
//  Storage.swift
//  Storage
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation

struct Storage {
//    fileprivate var storageToSQLite = StorageToSQLite.shareInstance
//    var storageToSQLite:StorageToSQLite {
//        return StorageToSQLite()
//    }
    fileprivate var storageToSQLite:StorageToSQLite = StorageToSQLite()
}

// MARK: - Select Table Data
extension Storage {
    public func objects() ->  StorageToSQLite {
        return StorageToSQLite()
    }
    
    public func object() -> StorageToSQLite {
        return StorageToSQLite()
    }
}

// MARK: - Select Table Data
extension Storage {
    public func count<T>(_ type:T.Type,filter:String = "") -> Int {
        var storageToSQLite = StorageToSQLite()
        let count = storageToSQLite.count(type,filter: filter)
        return count
    }
}

extension Storage {
    mutating func add<T>(_ object: T?, update:Bool = false) -> Bool {
        guard var object:T = object else {
            return false
        }
        //创建数据库
        if !storageToSQLite.tableIsExists(object){
            _ = storageToSQLite.createTable(&object)
        }
        
        //修改
        if update == true && storageToSQLite.count(object) > 0{
            return storageToSQLite.update(object)
        }
        return storageToSQLite.insert(&object)
    }
    
    mutating func addArray<T>(_ objectArray:[T]?) {
        guard let objectArray = objectArray else {
            return
        }
        for (_,element) in objectArray.enumerated() {
            _ = self.add(element,update: false)
        }
    }
}

extension Storage {
    mutating func update<T>(_ object:T?)  -> Bool {
        return self.add(object, update: true)
    }
}

// MARK: - Delete Table
extension Storage {
    public mutating func delete<T>(_ object:T?) -> Bool  {
        guard let object = object else {
            return false
        }
        return storageToSQLite.delete(object)
    }
    
    public mutating func deleteAll<T>(_ type:T.Type) -> Bool {
        return storageToSQLite.deleteAll(type)
    }
}

extension Storage {
    mutating func create<T>(_ type:T.Type , value:AnyObject) -> Void {
        if value is [String:AnyObject] {
            self.create(type, value: value as! [String:AnyObject])
        }else if value is [[String:AnyObject]] {
            self.create(type, value: value as! [[String:AnyObject]])
        }
    }
    
    mutating func create<T>(_ type:T.Type , value:[String:AnyObject]) -> Void {
//        let dataConversion =  DataConversion<T>()
//        let data = dataConversion.map(value)
//        _ = self.add(data)
    }
    
    mutating func create<T>(_ type:T.Type , value:[[String : AnyObject]]) -> Void {
//        let dataConversion =  DataConversion<T>()
//        let dataArray = dataConversion.mapArray(value)
//        self.addArray(dataArray)
    }
}


extension Storage {
    fileprivate  func tableName(_ objects:Any) -> String{
        let objectsMirror = Mirror(reflecting: objects)
        return String(describing: objectsMirror.subjectType)
    }
}

