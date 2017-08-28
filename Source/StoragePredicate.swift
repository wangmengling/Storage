//
//  StoragePredicate.swift
//  Storage
//
//  Created by utouu-imac on 2017/8/24.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation

enum StoragePredicateType {
    case SELECT
    case UPDATE
    case DELETE
}


protocol StoragePredicateProtocol: class {
    var storageToSQLite:StorageToSQLite {get set}
    var tableName:String {get set}
    var filter:String {get set}
    var sort:String {get set}
    var limit:String {get set}
    
    func filter(_ predicate: String) -> StoragePredicateProtocol
    func filter(_ predicate: NSPredicate) -> StoragePredicateProtocol
    func filter(_ predicate: [String:Any]) -> StoragePredicateProtocol
    func sorted(_ property: String, ascending: Bool) -> StoragePredicateProtocol
    func limit(_ pageIndex:Int,row:Int) -> StoragePredicateProtocol
    func limit(_ limit:Int) -> StoragePredicateProtocol
    
    func execute() -> Bool
}

extension StoragePredicateProtocol {
    func filter(_ predicate: String) -> StoragePredicateProtocol {
        var filter:String = ""
        if predicate.characters.count > 1 {
            filter = " Where "+predicate
        }
        self.filter = filter
        return self
    }
    
    func filter(_ predicate: NSPredicate) -> StoragePredicateProtocol {
        var filters:String = ""
        if predicate.predicateFormat.characters.count > 1 {
            filters = " Where " + predicate.predicateFormat
        }
        self.filter = filters
        return self
    }
    
    func filter(_ predicate: [String:Any]) -> StoragePredicateProtocol {
        return self
    }
    
    func sorted(_ property: String, ascending: Bool = false) -> StoragePredicateProtocol{
        if property.characters.count > 0 {
            self.sort = "order by \(property) " + (ascending == true ? "ASC" : "DESC")
        }
        return self
    }
}

extension StoragePredicateProtocol {
    func limit(_ pageIndex:Int,row:Int) -> StoragePredicateProtocol {
        self.limit = "LIMIT \(pageIndex * row),\(row)"
        return self
    }
    
    func limit(_ limit: Int) -> StoragePredicateProtocol {
        self.limit = "LIMIT \(limit)"
        return self
    }
}

public class StoragePredicateUpdate:StoragePredicateProtocol {
    
    
    
    var storageToSQLite: StorageToSQLite
    
    var filter: String = ""
    
    var tableName: String = ""
    
    var sort: String = ""
    
    var limit: String = ""
    
    init(_ storageToSQLite:StorageToSQLite) {
        self.storageToSQLite = storageToSQLite
    }
    
    func execute() -> Bool {
        return true
    }
}

public class StoragePredicate {
    
    fileprivate var storageToSQLite:StorageToSQLite
    fileprivate var tableName:String = ""
    fileprivate var filter:String = ""
    fileprivate var sort:String = ""
    fileprivate var limit:String = ""
    
    init(_ storageToSQLite:StorageToSQLite) {
        self.storageToSQLite = storageToSQLite
    }
}

// MARK: - SelectTable

extension StoragePredicate {
    
    fileprivate func objectsToSQLite() -> [[String : AnyObject]]? {
        let selectSQL = "SELECT * FROM  \(self.tableName) \(self.filter) \(self.sort) \(self.limit)"
        return storageToSQLite.objectsToSQLite(selectSQL)
    }
    
    fileprivate func objectToSQLite() -> [String : AnyObject]? {
        let selectSQL = "SELECT * FROM  \(self.tableName) \(self.filter)  \(self.sort) LIMIT 0,1"
        return storageToSQLite.objectToSQLite(selectSQL)
    }
}

// MARK: - filter sorted
extension StoragePredicate {
    
    public func filters(_ predicate:String) -> StoragePredicate{
        var filter:String = ""
        if predicate.characters.count > 1 {
            filter = " Where "+predicate
        }
        self.filter = filter
        return self
    }
    
    public func filter(predicate: NSPredicate) -> StoragePredicate {
        var filter:String = ""
        if predicate.predicateFormat.characters.count > 1 {
            filter = " Where " + predicate.predicateFormat
        }
        self.filter = filter
        return self
    }
    
    func sorted(_ property: String, ascending: Bool = false) -> StoragePredicate{
        if property.characters.count > 0 {
            self.sort = "order by \(property) " + (ascending == true ? "ASC" : "DESC")
        }
        return self
    }
    
    func limit(_ pageIndex:Int,row:Int) -> StoragePredicate {
        self.limit = "LIMIT \(pageIndex * row),\(row)"
        return self
    }
    
    func valueOfArray<T:Codable>(_ type:T.Type) -> Array<T> {
        self.tableName = String(describing: type)
        let dicArray = self.objectsToSQLite()
        let data:Data = try! JSONSerialization.data(withJSONObject: dicArray as Any, options: [])
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([T].self, from:data )
        {
            return decoded
        }
        return []
    }
    
    func value<T:Codable>(_ type:T.Type) -> T? {
        self.tableName = String(describing: type)
        let dic = self.objectToSQLite()
        let data:Data = try! JSONSerialization.data(withJSONObject: dic as Any, options: [])
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(T.self, from:data )
        {
            return decoded
        }
        return nil
    }
}
