//
//  StorageNominalType.swift
//  Storage
//
//  Created by jackWang on 2017/8/13.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation

struct StorageNominalType {
    private var metadata:StorageMetadata
    public init<T>(reflecting subject: T) {
        metadata = StorageMetadata(type: T.self)
    }
}

extension StorageNominalType {
    var pointer:UnsafePointer<NominalTypeDescriptor>? {
        return nil
    }
}

struct NominalTypeDescriptor {
    var mangledName: Int32 //offset 1
    var numberOfFields: Int32 //offset 2
    var fieldOffsetVector: Int32 //offset 3 This is the offset in pointer-sized words of the field offset vector for the type in the metadata record. If no field offset vector is stored in the metadata record, this is zero.
    var fieldNames: Int32 //offset 4
    var fieldTypesAccessor: Int32 //field type accessor is [a function] pointer at offset 5,If non-null, the function takes a pointer to an instance of type metadata for the nominal type, and returns a pointer to an array of type metadata references for the types of the fields of that instance. The order matches that of the field offset vector and field name list.
}

extension NominalTypeDescriptor{
    
    struct Class {
        var isa: UnsafePointer<Class>
        var super_: UnsafePointer<Class>
        var reserve1: Int
        var reserve2: Int
        
        var Data: Int
        var classFlags: Int32
        
        var instanceAdressPointer: Int32
        var instanceSize: Int32
        
        var instanceAlignMask: Int16
        var runtime_reserved: Int16
        
        var classobjectsize: Int32
        var classObjectAdressPointer: Int32
        
        // **offset 8** on a 64-bit platform or **offset 11** on a 32-bit platform.
        var Description : Int
        
        static var nominalTypeOffset: Int{
            return (MemoryLayout<Int>.size == MemoryLayout<Int64>.size) ? 8 : 11
        }
    }
}

extension NominalTypeDescriptor{
    
    struct Struct {
        var name: Int32
        var numberOfFields: Int32
        var fieldOffsetVector: Int32
        var fieldNames: Int32
        var fieldTypesAccessor: Int32
        static var nominalTypeOffset: Int{
            return 1
        }
    }
}

extension NominalTypeDescriptor{
    
    struct Enum {
        var name: Int32
        var NumPayloadCasesAndPayloadSizeOffset: Int32
        var NumEmptyCases: Int32
        var caseNames: Int32
        var caseTypes: Int32
    }
}
