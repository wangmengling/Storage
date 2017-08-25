//
//  Storage.swift
//  Storage
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation

/// Sqlite data manager for swift
struct Storage {
    fileprivate var storageToSQLite:StorageToSQLite = StorageToSQLite()
}

// MARK: - Select data
extension Storage {
    /// Select data
    ///
    /// - Parameter type: Type is inherit Codable Protocol
    /// - Returns: Filter, filter().sorted().limit().value()
    mutating public func object() -> StoragePredicate {
        return StoragePredicate(storageToSQLite)
    }
}

// MARK: - Count data number
extension Storage {
    
    /// Count data number
    ///
    /// - Parameters:
    ///   - type: Type is Struct or Class or Enum
    ///   - filter: String
    /// - Returns: Numbers
    public func count<T>(_ type:T.Type,filter:String = "") -> Int {
        var storageToSQLite = StorageToSQLite()
        let count = storageToSQLite.count(type,filter: filter)
        return count
    }
}


// MARK: - Insert data to sqlite
extension Storage {
    
    /// Insert a single piece of data into the database
    ///
    /// - Parameters:
    ///   - object: Added entity
    ///   - update: Whether it is updated (Requires inheritance protocol StorageProtocol)
    /// - Returns: Status
    mutating func add<T>(_ object: T?, update:Bool = false) -> Bool {
        guard var object:T = object else {
            return false
        }
        //create table if no exist
        if !storageToSQLite.tableIsExists(object){
            _ = storageToSQLite.createTable(&object)
        }
        
        //update
        if update == true && storageToSQLite.count(object) > 0{
            return storageToSQLite.update(object)
        }
        return storageToSQLite.insert(&object)
    }
    
    
    /// Insert the array into the database
    ///
    /// - Parameter objectArray: Added entity
    /// - Returns: Status
    mutating func addArray<T>(_ objectArray:[T]?)  -> Bool{
        guard let objectArray = objectArray else {
            return false
        }
        for (_,element) in objectArray.enumerated() {
            _ = self.add(element,update: false)
        }
        return true
    }
}


// MARK: - Create data
extension Storage {
    
    /// Insert the AnyObject into the database
    ///
    /// - Parameters:
    ///   - type: Type is inherit Codable Protocol
    ///   - value: Added entity
    /// - Returns: Status
    mutating func create<T:Codable>(_ type:T.Type , value:AnyObject) -> Bool {
        if value is [String:Any] {
            return self.create(type, value: value as! [String:Any])
        }else if value is [[String:Any]] {
            return self.create(type, value: value as! [[String:Any]])
        }
        return false
    }
    
    /// Insert the [String:Any] into the database
    ///
    /// - Parameters:
    ///   - type: Type is inherit Codable Protocol
    ///   - value: Added entity [String:Any]
    /// - Returns: Status
    mutating func create<T:Codable>(_ type:T.Type , value:[String:Any]) -> Bool {
        let data:Data = try! JSONSerialization.data(withJSONObject: value as Any, options: [])
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(T.self, from:data )
        {
            return self.add(decoded)
        }
        return false
    }
    
    /// Insert the [[String : Any]] into the database
    ///
    /// - Parameters:
    ///   - type: Type is inherit Codable Protocol
    ///   - value: Added entity [[String : Any]]
    /// - Returns: Status
    mutating func create<T:Codable>(_ type:T.Type , value:[[String : Any]]) -> Bool {
        let data:Data = try! JSONSerialization.data(withJSONObject: value as Any, options: [])
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([T].self, from:data )
        {
            return self.addArray(decoded)
        }
        return false
    }
}


// MARK: - Update data
extension Storage {
    
    /// Update data
    ///
    /// - Parameter object:Update entity (Requires inheritance protocol StorageProtocol)
    /// - Returns: Status
    mutating func update<T>(_ object:T?)  -> Bool {
        return self.add(object, update: true)
    }
}

// MARK: - Delete Table
extension Storage {
    
    /// Delete single data
    ///
    /// - Parameter object: Need to delete the entity
    /// - Returns: Status
    public mutating func delete<T>(_ object:T?) -> Bool  {
        guard let object = object else {
            return false
        }
        return storageToSQLite.delete(object)
    }
    
    /// Delete all data of type table
    ///
    /// - Parameter type: Need to delete the type
    /// - Returns: Status
    public mutating func deleteAll<T>(_ type:T.Type) -> Bool {
        return storageToSQLite.deleteAll(type)
    }
}

// MARK: - Get the table name
extension Storage {
    
    /// Get the table name
    ///
    /// - Parameter objects: Entity object
    /// - Returns: TableName
    fileprivate  func tableName(_ object:Any) -> String{
        let objectsMirror = Mirror(reflecting: object)
        return String(describing: objectsMirror.subjectType)
    }
}

