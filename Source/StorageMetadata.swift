//
//  StorageMetadata.swift
//  Storage
//
//  Created by jackWang on 2017/8/13.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation


struct StorageMetadata: StoragePointerProtocol {
    var pointer: UnsafePointer<Int>
    init(type: Any.Type) {
        print(unsafeBitCast(type, to: UnsafePointer<Int>.self).pointee)
        self.init(pointer: unsafeBitCast(type, to: UnsafePointer<Int>.self))
    }
}

extension StorageMetadata {
    var kind:Kind {
        return .class
    }
    var nominalTypeDescriptorOffset:Int {
        return 0
    }
    
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



protocol StoragePointerProtocol : Equatable {
    associatedtype Pointee //Metadata Type
    var pointer: UnsafePointer<Pointee> { get set }
}
extension StoragePointerProtocol {
    init<T>(pointer: UnsafePointer<T>) {
        func cast<T, U>(_ value: T) -> U {
            print(U.self)
            return unsafeBitCast(value, to: U.self)
        }
        print(UnsafePointer<Pointee>(pointer),UnsafePointer<Pointee>(pointer).pointee)
        self = cast(UnsafePointer<Pointee>(pointer))
    }
}
func == <T: StoragePointerProtocol>(lhs: T, rhs: T) -> Bool {
    return lhs.pointer == rhs.pointer
}

extension UnsafePointer {
    init<T>(_ pointer: UnsafePointer<T>) {
        print(UnsafeRawPointer(pointer).assumingMemoryBound(to: Pointee.self),UnsafeRawPointer(pointer).assumingMemoryBound(to: Pointee.self).pointee)
        self = UnsafeRawPointer(pointer).assumingMemoryBound(to: Pointee.self)
    }
}
