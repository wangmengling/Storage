//
//  StoragePointer.swift
//  Storage
//
//  Created by jackWang on 2017/7/23.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
extension Encodable {
    mutating func headPointerOfStruct() -> UnsafeMutablePointer<Int8> {
        return withUnsafeMutablePointer(to: &self) {
            return UnsafeMutableRawPointer($0).bindMemory(to: Int8.self, capacity: MemoryLayout<Self>.stride)
        }
    }
    
    //获取 class 类型实例的指针，From HandyJSON
    func headPointerOfClass() -> UnsafeMutablePointer<Int8> {
        let opaquePointer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
        let mutableTypedPointer = opaquePointer.bindMemory(to: Int8.self, capacity: MemoryLayout<Self>.stride)
        return UnsafeMutablePointer<Int8>(mutableTypedPointer)
    }
}

struct StoragePointer {
    var pointer:UnsafePointer<Int>?
    
    mutating func deCodeable<T>(_ object:inout T) -> Void {
        
//        var children = [(label: String?, value: Any)]()
        let mirror = Mirror(reflecting: object)
        var children = [(label: String?, value: Any)]()
        let mirrorChildrenCollection = AnyRandomAccessCollection(mirror.children)!
        children += mirrorChildrenCollection
        
        var currentMirror = mirror
        while let superclassChildren = currentMirror.superclassMirror?.children {
            let randomCollection = AnyRandomAccessCollection(superclassChildren)!
            children += randomCollection
            currentMirror = currentMirror.superclassMirror!
        }
        let pointer = self.headPointerOfStruct(&object)
        let animalRawPtr = UnsafeMutableRawPointer(pointer)
        
        let d = animalRawPtr.assumingMemoryBound(to: T.self)
        print(d.pointee)
        let aPtr = animalRawPtr.advanced(by: 0).assumingMemoryBound(to: String.self)
        print(aPtr.pointee)
    }
    
    //获取 struct 类型实例的指针
    mutating func headPointerOfStruct<T>(_ object:inout T) -> UnsafeMutablePointer<Int8> {
        return withUnsafeMutablePointer(to: &object) {
            return UnsafeMutableRawPointer($0).bindMemory(to: Int8.self, capacity: MemoryLayout<T>.stride)
        }
    }
    
    //获取 class 类型实例的指针
    func headPointerOfClass<T>(_ object:inout T) -> UnsafeMutablePointer<Int8> {
        let opaquePointer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
        let mutableTypedPointer = opaquePointer.bindMemory(to: Int8.self, capacity: MemoryLayout<T>.stride)
        return UnsafeMutablePointer<Int8>(mutableTypedPointer)
    }
}

