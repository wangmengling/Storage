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
    var type:Int
    var count:Int
}

struct StorageTypeDescriptor{
    
    var name: Int32
    var numberOfFields: Int32
    var FieldOffsetVectorOffset: Int32
    var fieldNames: Int32
    var fieldTypes: Int32
    var fieldTypess: Int32
}

struct StoragePointer {
    var pointer:UnsafePointer<Int>?
    
    mutating func deCodeable<T>(_ object:inout T) -> Void {
        let intsPointer = unsafeBitCast(T.self, to: UnsafePointer<Int>.self) //获取地址
        //获取地址
        print(1,intsPointer,intsPointer.pointee)
//        let secondPointer = intsPointer.advanced(by: 0)
//        print(T.self, "pointer is", secondPointer.pointee)
        let typePointer = unsafeBitCast(T.self, to: UnsafePointer<StorageOff>.self) //转换获取（偏移量）
        print(2,T.self, "pointer is", typePointer,typePointer.pointee)
//        StorageModel pointer is 0x0000000123f961a8 StorageOff(kind: 1, nominalTypeDescriptorOffset: -1936, type: 0, count: 4898510144)
//        StorageModel pointer is 0x00000001213d6218 StorageOff(kind: 1, nominalTypeDescriptorOffset: -2224, type: 0, count: 0)
//        StorageModel pointer is 0x0000000123c60230 StorageOff(kind: 1, nominalTypeDescriptorOffset: -2304, type: 0, count: 0)
//        StorageModel pointer is 0x000000011ed49238 StorageOff(kind: 1, nominalTypeDescriptorOffset: -2312, type: 0, count: 0)
//        StorageModel pointer is 0x000000011ffba238 StorageOff(kind: 1, nominalTypeDescriptorOffset: -2496, type: 0, count: 0)
//        print(typePointer.pointee.nominalTypeDescriptorOffset)
        let intPointer = unsafeBitCast(typePointer, to: UnsafePointer<Int>.self) //获取转换地址 其实这里不用转换了，直接获取上面的第一个intsPointer
        print(3,intPointer,intPointer.pointee)
//
        let nominalTypeBase = intsPointer.advanced(by: 1)
        print(4,nominalTypeBase,nominalTypeBase.pointee)
        let int8Type = unsafeBitCast(nominalTypeBase, to: UnsafePointer<Int8>.self) //转换 nominalTypeDescriptorOffset 的地址
        print(6,int8Type,int8Type.pointee)
        let nominalTypePointer = int8Type.advanced(by: typePointer.pointee.nominalTypeDescriptorOffset) //取下偏移ofsset后的 poiner
        print(7,nominalTypePointer,nominalTypePointer.pointee)
        
//
//        
        let nominalType = unsafeBitCast(nominalTypePointer, to: UnsafePointer<StorageTypeDescriptor>.self) //根据偏移获得到的pointer 转换成StorageTypeDescriptor 获取到内存中记录的数据
        print(8,nominalType,nominalType.pointee)
        print(1)
//        0x00000001193b9a20 StorageTypeDescriptor(name: -32, numberOfFields: 0, FieldOffsetVectorOffset: 3, fieldNames: -20, fieldTypes: -1120, fieldTypess: 1)
//        0x000000011ab72970 StorageTypeDescriptor(name: -32, numberOfFields: 1, FieldOffsetVectorOffset: 3, fieldNames: -20, fieldTypes: -1648, fieldTypess: 1)
//        let numberOfField = Int(nominalType.pointee.numberOfFields)
//        0x000000011bd3e938 StorageTypeDescriptor(name: -40, numberOfFields: 2, FieldOffsetVectorOffset: 3, fieldNames: -28, fieldTypes: -1864, fieldTypess: 1)
//        0x000000011cbe18e8 StorageTypeDescriptor(name: -56, numberOfFields: 3, FieldOffsetVectorOffset: 3, fieldNames: -36, fieldTypes: -1864, fieldTypess: 1)
//        0x000000012496d8e0 StorageTypeDescriptor(name: -64, numberOfFields: 4, FieldOffsetVectorOffset: 3, fieldNames: -44, fieldTypes: -1888, fieldTypess: 1)
//        let int32NominalFunc = unsafeBitCast(nominalType, to: UnsafePointer<Int32>.self).advanced(by: 4)
//        let nominalFunc = unsafeBitCast(int32NominalFunc, to: UnsafePointer<Int8>.self).advanced(by: Int(nominalType.pointee.fieldTypes))
//        0x00000001208c78a8 StorageTypeDescriptor(name: -72, numberOfFields: 5, FieldOffsetVectorOffset: 3, fieldNames: -52, fieldTypes: -1896, fieldTypess: 1)
//        0x0000000126156880 StorageTypeDescriptor(name: -80, numberOfFields: 6, FieldOffsetVectorOffset: 3, fieldNames: -60, fieldTypes: -1936, fieldTypess: 1)
        let numberOfField = Int(nominalType.pointee.numberOfFields)
        
//        let int32NominalType = unsafeBitCast(nominalType, to: UnsafePointer<Int32>.self)
//        let fieldBase = int32NominalType.advanced(by: 3)//.advanced(by: Int(nominalType.pointee.FieldOffsetVectorOffset))
        
//        let int8FieldBasePointer = unsafeBitCast(fieldBase, to: UnsafePointer<Int8>.self)
//        let fieldNamePointer = int8FieldBasePointer.advanced(by: Int(nominalType.pointee.fieldNames))
        
//        let fieldNames = getFieldNames(pointer: fieldNamePointer, fieldCount: numberOfField)
//        superObject.propertyNames.append(contentsOf: fieldNames)
        
        let int32NominalFunc = unsafeBitCast(nominalType, to: UnsafePointer<Int32>.self).advanced(by: 4)
        print(9,int32NominalFunc,int32NominalFunc.pointee)
        let nominalFunc = unsafeBitCast(int32NominalFunc, to: UnsafePointer<Int8>.self).advanced(by: Int(nominalType.pointee.fieldTypes))
        let fieldType = getType(pointer: nominalFunc, fieldCount: numberOfField)
//        print(fieldType)
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
