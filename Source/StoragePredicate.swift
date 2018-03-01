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
    var predicateType:StoragePredicateType {get set}
    
    func filter(_ predicate: String) -> StoragePredicateProtocol
    func filter(_ predicate: NSPredicate) -> StoragePredicateProtocol
    func filter(_ predicate: [String:Any]) -> StoragePredicateProtocol
    
    func sorted(_ property: String, ascending: Bool) -> StoragePredicateProtocol
    
    func limit(_ pageIndex:Int,row:Int) -> StoragePredicateProtocol
    func limit(_ limit:Int) -> StoragePredicateProtocol
    
    func execute() -> Bool
    
    func value<T:Codable>(_ type:T.Type) -> T?
    func valueOfArray<T:Codable>(_ type:T.Type) -> Array<T>
}

extension StoragePredicateProtocol {
    func filter(_ predicate: String) -> StoragePredicateProtocol {
        var filter:String = ""
        if predicate.count > 1 {
            filter = " Where "+predicate
        }
        self.filter = filter
        return self
    }
    
    func filter(_ predicate: NSPredicate) -> StoragePredicateProtocol {
        var filters:String = ""
        if predicate.predicateFormat.count > 1 {
            filters = " WHERE " + predicate.predicateFormat
        }
        self.filter = filters
        return self
    }
    
    func filter(_ filters: [String:Any]) -> StoragePredicateProtocol {
        var filterAssembly = ""
        filters.forEach { (arg) in
            guard let value:String = self.storageToSQLite.proToColumnValues(arg.value), value.count > 0 else { return  }
            filterAssembly += "\(arg.key) = \(String(describing: value))"
        }
        if filterAssembly.count > 1 {
            filterAssembly = filterAssembly.subString(0, length: filterAssembly.count - 1)
        }
        if filters.count > 0 {
            filterAssembly = "Where \(filterAssembly)"
        }
        self.filter = filterAssembly;
        return self
    }
}

extension StoragePredicateProtocol {
    func sorted(_ property: String, ascending: Bool = false) -> StoragePredicateProtocol{
        if property.count > 0 {
            self.sort = "order by \(property) " + (ascending == true ? "ASC" : "DESC")
        }
        return self
    }
}

extension StoragePredicateProtocol {
    func limit(_ pageIndex:Int = 0,row:Int = 10) -> StoragePredicateProtocol {
        if self.predicateType == .SELECT {
            self.limit = "LIMIT \(pageIndex * row),\(row)"
        }else {
            self.limit = "LIMIT \(limit)"
        }
        return self
    }
    
    func limit(_ limit: Int = 1) -> StoragePredicateProtocol {
        self.limit = "LIMIT \(limit)"
        return self
    }
}

extension StoragePredicateProtocol {
    func execute() -> Bool {
        return false
    }
    
    func value<T:Codable>(_ type:T.Type) -> T? {
        return nil
    }
    func valueOfArray<T:Codable>(_ type:T.Type) -> Array<T> {
        return []
    }
}


/// Update
public class StoragePredicateUpdate:StoragePredicateProtocol {
    var storageToSQLite: StorageToSQLite
    
    var filter: String = ""
    
    var tableName: String = ""
    
    var sort: String = ""
    
    var limit: String = ""
    
    var updateValues = ""
    
    var predicateType:StoragePredicateType
    
    var values:[String:Any]
    
    init<T>(_ storageToSQLite:StorageToSQLite, _ type:T.Type, _ values:[String:Any]) {
        self.storageToSQLite = storageToSQLite
        self.values = values
        self.predicateType = .UPDATE
        self.updateValues(type)
    }
    
    
    private func updateValues<T>(_ type:T.Type) {
        if values.count < 1 {
            return
        }
        self.tableName = String(describing: type)
        let storageMirror = StorageMirror(reflecting: type)
        let valueAssembly = self.updateAssemblyResult(values, storageMirror)
        self.updateValues = valueAssembly
    }
    
    fileprivate func updateAssemblyResult(_ values:[String:Any], _ storageMirror:StorageMirror)  -> String{
        var sql = ""
        
        values.forEach { (arg) in
            let type = storageMirror.getType(arg.key)
            guard let fieldType = type else { return  }
            guard let value:String = self.storageToSQLite.proToColumnValues(fieldType, arg.value), value.count > 0 else { return  }
            sql += "\(arg.key) = \(String(describing: value))"
        }
        if sql.count > 1 {
            sql = sql.subString(0, length: sql.count - 1)
        }
        return sql
    }
}

extension StoragePredicateUpdate {
    func execute() -> Bool {
        return storageToSQLite.update(self.tableName, self.updateValues, self.filter, self.sort, self.limit)
    }
}

/// Delete
public class StoragePredicateDelete:StoragePredicateProtocol {
    var storageToSQLite: StorageToSQLite
    
    var filter: String = ""
    
    var tableName: String = ""
    
    var sort: String = ""
    
    var limit: String = ""
    
    var predicateType:StoragePredicateType
    
    init<T>(_ storageToSQLite:StorageToSQLite, _ type:T.Type) {
        self.tableName = String(describing: type)
        self.storageToSQLite = storageToSQLite
        self.predicateType = .DELETE
    }
}

extension StoragePredicateDelete {
    func execute() -> Bool {
        return storageToSQLite.deleteWhere(self.tableName, self.filter, self.sort, self.limit)
    }
}


/// Select
public class StoragePredicateSelect:StoragePredicateProtocol {
     var storageToSQLite:StorageToSQLite
     var tableName:String = ""
     var filter:String = ""
     var sort:String = ""
     var limit:String = ""
    var predicateType:StoragePredicateType
    init(_ storageToSQLite:StorageToSQLite) {
        self.storageToSQLite = storageToSQLite
        self.predicateType = .SELECT
    }
}

// MARK: - SelectTable

extension StoragePredicateSelect {
    
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
extension StoragePredicateSelect {
    
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
