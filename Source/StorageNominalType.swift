//
//  StorageNominalType.swift
//  Storage
//
//  Created by jackWang on 2017/8/13.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
struct StorageNominalTypeDescriptor {
    var mangledName: Int32 //offset 1
    var numberOfFields: Int32 //offset 2
    var fieldOffsetVector: Int32 //offset 3 This is the offset in pointer-sized words of the field offset vector for the type in the metadata record. If no field offset vector is stored in the metadata record, this is zero.
    var fieldNames: Int32 //offset 4
    var fieldTypeAccessor: Int32 //field type accessor is [a function] pointer at offset 5,If non-null, the function takes a pointer to an instance of type metadata for the nominal type, and returns a pointer to an array of type metadata references for the types of the fields of that instance. The order matches that of the field offset vector and field name list.
}
