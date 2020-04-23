//
//  StorageProtocol.swift
//  Storage
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
protocol StorageProtocol {
    func primaryKey() -> String
}


extension StorageProtocol {
    func filter() -> StoragePredicateProtocol {
        
    }
}

extension StorageProtocol {
    func delete() -> Bool {
        return true
    }
    func add() -> Void {
        
    }
    func update() -> Void{
        
    }
}



public extension RawRepresentable where Self: Codable {
    
//    func takeRawValue() -> Any? {
//        return self.rawValue
//    }
    
    static func transform() -> Self? {
        if RawValue.self is Codable.Type {
            return self as? Self
        }
        return nil
    }
}
