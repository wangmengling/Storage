//
//  StorageMirror.swift
//  Storage
//
//  Created by utouu-imac on 2017/8/15.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
public struct StorageMirror {
    private let pointer:StorageMetadata
    
    public init<T>(reflecting subject: T) {
        pointer = StorageMetadata(type: T.self)
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
        return "";
    }
    
    /// The fields num of the subject being reflected.
    public var numberOfFields: Int {
        return 0
    }
    
    /// The field names of the subject being reflected.
    public var fieldNames: [String] {
        return []
    }
    
    /// The field types of the subject being reflected.
    public var fieldTypes: [Any.Type] {
        return []
    }
}

/// Reflection for `StorageMirror` itself.
extension StorageMirror : CustomStringConvertible {
    public var description: String {
        return "";
    }
}
