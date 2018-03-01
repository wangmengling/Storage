//
//  StorageProtocol.swift
//  Storage
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
protocol StorageProtocol {
    func primaryKey() -> String
}

extension StorageProtocol {
    func primaryKey() -> String {
        return ""
    }
}

extension StorageProtocol {
    public static func transforms() -> Self {
        print(self)
        return self as! Self
    }

}

extension Decodable {
    public static func transforms() -> Self {
        print(self)
        print(self)
        return self as! Self
    }
}

extension Encodable {
    public static func transforms() -> Self {
        return self as! Self
    }
}

//extension StorageProtocol : Encodable {
//
//    /// Encodes this value into the given encoder.
//    ///
//    /// If the value fails to encode anything, `encoder` will encode an empty
//    /// keyed container in its place.
//    ///
//    /// This function throws an error if any values are invalid for the given
//    /// encoder's format.
//    ///
//    /// - Parameter encoder: The encoder to write data to.
//    public func encode(to encoder: Encoder) throws
//}
//
//extension StorageProtocol : Decodable {
//
//    /// Creates a new instance by decoding from the given decoder.
//    ///
//    /// This initializer throws an error if reading from the decoder fails, or
//    /// if the data read is corrupted or otherwise invalid.
//    ///
//    /// - Parameter decoder: The decoder to read data from.
//    public init(from decoder: Decoder) throws
//}



public extension RawRepresentable where Self: Codable {
    
//    func takeRawValue() -> Any? {
//        return self.rawValue
//    }
    
    static func transform() -> Self? {
        if RawValue.self is Codable.Type {
            return self as! Self
        }
        return nil
    }
}
