//
//  Storage.swift
//  Storage
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation

/// Sqlite data manager for swift
public struct Storage {
    fileprivate var storageToSQLite:StorageToSQLite = StorageToSQLite()
}

// MARK: - Select data
extension Storage {
    /// Select data
    ///
    /// - Parameter type: Type is inherit Codable Protocol
    /// - Returns: Filter, filter().sorted().limit().value()
    mutating public func object() -> StoragePredicateSelect {
        return StoragePredicateSelect(storageToSQLite)
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
    mutating public func add<T>(_ object: T, update:Bool = false) -> Bool {
        let object:T = object
        //create table if no exist
        if storageToSQLite.createTable(type(of: object)){
            //update
            if update == true && storageToSQLite.count(object) > 0{
                return storageToSQLite.updatePrimaryKey(object)
            }
            return storageToSQLite.insert(object)
        }
        return false
    }
    
    
    /// Insert a single piece of data into the database
    ///
    /// - Parameters:
    ///   - object: Added entity
    ///   - update: Whether it is updated (Requires inheritance protocol StorageProtocol)
    /// - Returns: Status
    mutating public func add<T>(_ object: T?, update:Bool = false) -> Bool {
        guard let object:T = object else {
            return false
        }
        return add(object, update: update)
    }
    
    
    /// Insert the array into the database
    ///
    /// - Parameter objectArray: Added entity
    /// - Returns: Status
    mutating public func addArray<T>(_ objectArray:[T])  -> Bool{
        for (_,element) in objectArray.enumerated() {
            _ = self.add(element,update: false)
        }
        return true
    }
    
    /// Insert the array into the database
    ///
    /// - Parameter objectArray: Added entity
    /// - Returns: Status
    mutating public func addArray<T>(_ objectArray:[T]?)  -> Bool{
        guard let objectArray = objectArray else {
            return false
        }
        return addArray(objectArray)
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
    mutating public func create<T:Codable>(_ type:T.Type , value:AnyObject) -> Bool {
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
    mutating public func create<T:Codable>(_ type:T.Type , value:[String:Any]) -> Bool {
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
    mutating public func create<T:Codable>(_ type:T.Type , value:[[String : Any]]) -> Bool {
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
    mutating public func update<T>(_ object:T?)  -> Bool {
        return self.add(object, update: true)
    }
    
    public func update<T>(_ type:T.Type, _ values:[String:Any]) -> StoragePredicateUpdate {
        return StoragePredicateUpdate(storageToSQLite, type, values)
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
    
    /// Delete single data
    ///
    /// - Parameter object: Need to delete the entity
    /// - Returns: Status
    public mutating func delete<T>(_ type:T.Type) -> StoragePredicateDelete  {
        return StoragePredicateDelete(self.storageToSQLite, type)
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

