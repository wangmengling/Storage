//
//  StorageMetadata.swift
//  Storage
//
//  Created by jackWang on 2017/8/13.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation



protocol StorageMetadataProtocol {
    
}

struct StorageMetadata: StorageMetadataProtocol {
    var kind:Kind
    var nominalTypeDescriptorOffset:Int
    
    enum Kind {
        case `struct`
        case `enum`
        case tuple
        case function
        case `protocol`
        case metatype
        case `class`
        init(flag: Int) {
            switch flag {
            case 1: self = .struct
            case 2: self = .enum
            case 9: self = .tuple
            case 10: self = .function
            case 12: self = .protocol
            case 13: self = .metatype
            default: self = .class
            }
        }
    }
}





struct Metadata {
    struct Struct {
        var kind: Int
        var nominalTypeDescriptorOffset: Int
        var parent: Metadata?
    }
    
    struct Class {
        var kind: Int
        var superclass: Any.Type?
        var reserveword1: Int
        var reserveword2: Int
        var databits: UInt
        // other fields we don't care
    }
    
    struct ObjcClassWrapper {
        var kind: Int
        var targetType: Any.Type?
    }
}
