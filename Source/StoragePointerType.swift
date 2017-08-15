//
//  StoragePointerType.swift
//  Storage
//
//  Created by utouu-imac on 2017/8/15.
//  Copyright © 2017年 jackWang. All rights reserved.
//

//import Foundation
protocol PointerType : Equatable {
    associatedtype Pointee
    var pointer: UnsafePointer<Pointee> { get set }
}

extension PointerType {
    init<T>(pointer: UnsafePointer<T>) {
        func cast<T, U>(_ value: T) -> U {
            print(value,U.self,T.self)
            return unsafeBitCast(value, to: U.self)
        }
        self = cast(UnsafePointer<Pointee>(pointer))
    }
}

func == <T: PointerType>(lhs: T, rhs: T) -> Bool {
    return lhs.pointer == rhs.pointer
}
