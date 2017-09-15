//
//  StorageMirror.swift
//  Storage
//
//  Created by utouu-imac on 2017/8/15.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
public struct StorageMirror {
    fileprivate let storageNominalType:StorageNominalType
    var mirror:Mirror
    
    public init<T>(reflecting subject:T) {
        mirror = Mirror(reflecting: subject)
        storageNominalType = StorageNominalType(reflecting: subject)
    }
    
    
//    public init<T>(reflecting type:  T.Type) {
//        mirror = Mirror(reflecting: type)
//        storageNominalType = StorageNominalType(reflecting: type);
//    }
    
    public init(_ anyType:Any.Type) {
        mirror = Mirror(reflecting: anyType)
        storageNominalType = StorageNominalType(reflecting: anyType);
    }
}

extension StorageMirror {
    /// The static type of the subject being reflected.
    ///
    /// This type may differ from the subject's dynamic type when `self`
    /// is the `superclassMirror` of another mirror.
    public var subjectType: Any.Type {
        return String.self;
    }
    
    /// The name of the subject being reflected.
    public var mangledName: String {
        guard let nominalTypeDescriptorointer  = storageNominalType.nominalTypeDescriptorointer else {
            return ""
        }
        let p = UnsafePointer<Int32>(nominalTypeDescriptorointer)
        let fieldBase = p.advanced(by: Int(nominalTypeDescriptorointer.pointee.fieldOffsetVector))
        return String(cString: relativePointer(base: fieldBase, offset: nominalTypeDescriptorointer.pointee.mangledName) as UnsafePointer<CChar>)
    }
    
    /// The fields num of the subject being reflected.
    public var numberOfFields: Int? {
        guard let nominalTypeDescriptorointer  = storageNominalType.nominalTypeDescriptorointer else {
            return 0
        }
        return Int(nominalTypeDescriptorointer.pointee.numberOfFields)
    }
    
    /// The field names of the subject being reflected.
    var fieldNames: [String] {
        guard let nominalTypeDescriptorointer  = storageNominalType.nominalTypeDescriptorointer else {
            return []
        }
        let p = UnsafePointer<Int32>(nominalTypeDescriptorointer)
        
        return Array(utf8Strings: relativePointer(base: p.advanced(by: 3), offset: nominalTypeDescriptorointer.pointee.fieldNames))
    }
    
    /// The field types of the subject being reflected.
    var fieldTypes: [Any.Type] {
        guard let nominalTypeDescriptorointer = storageNominalType.nominalTypeDescriptorointer else {
            return []
        }
        let nominalType = UnsafePointer<Int32>(nominalTypeDescriptorointer)
        print(nominalType,nominalTypeDescriptorointer)
        let nominalTypeFunc: UnsafePointer<Int> = relativePointer(base: nominalType.advanced(by: 4), offset: nominalTypeDescriptorointer.pointee.fieldTypesAccessor)
        
        let types = self.getType(pointer: nominalTypeFunc, fieldCount: self.numberOfFields ?? 0)
        return types
    }
}

extension StorageMirror {
    fileprivate func getType(pointer nominalFunc: UnsafePointer<Int>, fieldCount numberOfField: Int) -> [Any.Type]{
        
        let function = unsafeBitCast(nominalFunc, to: FieldTypesAccessor.self)
        let funcBase = function(nominalFunc)
        
        var types: [Any.Type] = []
        for i in 0..<numberOfField {
            let typeFetcher = funcBase.advanced(by: i).pointee
            let type:Any.Type = unsafeBitCast(typeFetcher, to: Any.Type.self)
            types.append(type)
        }
        
        return types
    }
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

func relativePointer<T, U, V>(base: UnsafePointer<T>, offset: U) -> UnsafePointer<V> where U : BinaryInteger {
    return UnsafeRawPointer(base).advanced(by: Int(integer: offset)).assumingMemoryBound(to: V.self)
}

extension Int {
    fileprivate init<T : BinaryInteger>(integer: T) {
        switch integer {
        case let value as Int: self = value
        case let value as Int32: self = Int(value)
        case let value as Int16: self = Int(value)
        case let value as Int8: self = Int(value)
        default: self = 0
        }
    }
}

protocol UTF8Initializable {
    init?(validatingUTF8: UnsafePointer<CChar>)
}

extension String : UTF8Initializable {}

extension Array where Element : UTF8Initializable {
    
    init(utf8Strings: UnsafePointer<CChar>) {
        var strings = [Element]()
        var p = utf8Strings
        while let string = Element(validatingUTF8: p) {
            strings.append(string)
            while p.pointee != 0 {
                p = p.advanced(by: 1)
            }
            p = p.advanced(by: 1)
            guard p.pointee != 0 else { break }
        }
        self = strings
    }
}
