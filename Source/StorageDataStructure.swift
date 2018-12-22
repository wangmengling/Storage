//
//  StorageDataStructure.swift
//  Storage
//
//  Created by jackWang on 2018/12/21.
//  Copyright © 2018年 jackWang. All rights reserved.
//

import Foundation
struct StorageMirror {
    var mirror:Mirror
    
    public init<T>(reflecting subject:T) {
        mirror = Mirror(reflecting: subject)
        
        mirror.children.forEach { (label,value) in
            fieldNames.append(label ?? "")
            fieldTypes.append(type(of: value))
        }
    }
    
//    public init(_ anyType:Any.Type) {
//        mirror = Mirror(reflecting: anyType)
//        
//        mirror.children.forEach { (label,value) in
//            fieldNames.append(label ?? "")
//            fieldTypes.append(type(of: value))
//        }
//    }
    
    var fieldNames: [String] = []
    var fieldTypes: [Any.Type] = []
}



extension StorageMirror {
    func getType(_ name:String) -> Any.Type? {
        let index = self.fieldNames.index(of: name)
        guard let indexG = index else {
            return nil
        }
        return self.fieldTypes[indexG]
    }
}

/// Reflection for `StorageMirror` itself.
extension StorageMirror : CustomStringConvertible {
    public var description: String {
        return "";
    }
}
