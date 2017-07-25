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

struct StorageOff {
    var kind: Int
    var nominalTypeDescriptorOffset: Int
}

struct StorageTypeDescriptor{
    
    var name: Int32
    var numberOfFields: Int32
    var FieldOffsetVectorOffset: Int32
    var fieldNames: Int32
    var fieldTypes: Int32
}

struct StoragePointer {
    var pointer:UnsafePointer<Int>?
    
    mutating func deCodeable<T>(_ object:inout T) -> Void {
        let intsPointer = unsafeBitCast(T.self, to: UnsafePointer<Int>.self)
        intsPointer.advanced(by: 0)
        print(T.self, "pointer is", intsPointer.pointee)
        let typePointer = unsafeBitCast(T.self, to: UnsafePointer<StorageOff>.self)
        print(T.self, "pointer is", typePointer)
        print(typePointer.pointee.nominalTypeDescriptorOffset)
        let intPointer = unsafeBitCast(typePointer, to: UnsafePointer<Int>.self)
        
        let nominalTypeBase = intPointer.advanced(by: 1)
        let int8Type = unsafeBitCast(nominalTypeBase, to: UnsafePointer<Int8>.self)
        let nominalTypePointer = int8Type.advanced(by: typePointer.pointee.nominalTypeDescriptorOffset)
        
        
        let nominalType = unsafeBitCast(nominalTypePointer, to: UnsafePointer<StorageTypeDescriptor>.self)
        let numberOfField = Int(nominalType.pointee.numberOfFields)
        
        
        let int32NominalFunc = unsafeBitCast(nominalType, to: UnsafePointer<Int32>.self).advanced(by: 4)
        let nominalFunc = unsafeBitCast(int32NominalFunc, to: UnsafePointer<Int8>.self).advanced(by: Int(nominalType.pointee.fieldTypes))
        
        let fieldType = getType(pointer: nominalFunc, fieldCount: numberOfField)
        print(fieldType)
//        let offsetPointer = intPointer.advanced(by: Int(nominalType.pointee.FieldOffsetVectorOffset))
//        var offsetArr: [Int] = []
//
//        for i in 0..<numberOfField {
//            let offset = offsetPointer.advanced(by: i)
//            offsetArr.append(offset.pointee)
//        }
//        let pointer = self.headPointerOfStruct(&object)
//        let animalRawPtr = UnsafeMutableRawPointer(pointer)
//
//        let d = animalRawPtr.assumingMemoryBound(to: T.self)
//        print(d.pointee)
//        let aPtr = animalRawPtr.advanced(by: 0).assumingMemoryBound(to: String.self)
//
//        print(aPtr.pointee)
    }
    
    mutating func s<T>(_ object:inout T) -> Void {
                let pointer = self.headPointerOfStruct(&object)
                let animalRawPtr = UnsafeMutableRawPointer(pointer)
        
                let d = animalRawPtr.assumingMemoryBound(to: T.self)
//                print(d.pointee)
//                let aPtr = animalRawPtr.advanced(by: 0).assumingMemoryBound(to: String.self)
//
//                print(aPtr.pointee)
        
        let objectP = animalRawPtr.advanced(by: 0).assumingMemoryBound(to: Any?.self)
        print(objectP.pointee)
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
typealias FieldsTypeAccessor = @convention(c) (UnsafePointer<Int>) -> UnsafePointer<UnsafePointer<Int>>
private func getType(pointer nominalFunc: UnsafePointer<Int8>, fieldCount numberOfField: Int) -> [Any.Type]{
    
    let funcPointer = unsafeBitCast(nominalFunc, to: FieldsTypeAccessor.self)
    let funcBase = funcPointer(unsafeBitCast(nominalFunc, to: UnsafePointer<Int>.self))
    
    
    var types: [Any.Type] = []
    for i in 0..<numberOfField {
        let typeFetcher = funcBase.advanced(by: i).pointee
        let type = unsafeBitCast(typeFetcher, to: Any.Type.self)
        types.append(type)
    }
    
    return types
}

struct Meta {
    var numberOfFields: Int32
    var fieldOffset: Int32
    var fieldNames: Int32
    var fieldTypes: Int32
}

func relativePointer<T, V>(base: UnsafePointer<T>, offset: Int) -> UnsafePointer<V>{
    print(UnsafeRawPointer(base).advanced(by: offset).assumingMemoryBound(to: V.self))
    print(type(of: V.self))
    return UnsafeRawPointer(base).advanced(by:  offset).assumingMemoryBound(to: V.self)
}
