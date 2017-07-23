//
//  StoragePointer.swift
//  Storage
//
//  Created by jackWang on 2017/7/23.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
struct StoragePointer {
    
}


//final func withUnsafeMutablePointers<R>(_ body: (UnsafeMutablePointer<Header>, UnsafeMutablePointer<Element>) throws -> R) rethrows -> R
//
////基本数据类型
//var a: T = T()
//var aPointer = a.withUnsafeMutablePointer{ return $0 }
//
////获取 struct 类型实例的指针，From HandyJSON
//func headPointerOfStruct() -> UnsafeMutablePointer<Int8> {
//    return withUnsafeMutablePointer(to: &self) {
//        return UnsafeMutableRawPointer($0).bindMemory(to: Int8.self, capacity: MemoryLayout<Self>.stride)
//    }
//}
//
////获取 class 类型实例的指针，From HandyJSON
//func headPointerOfClass() -> UnsafeMutablePointer<Int8> {
//    let opaquePointer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
//    let mutableTypedPointer = opaquePointer.bindMemory(to: Int8.self, capacity: MemoryLayout<Self>.stride)
//    return UnsafeMutablePointer<Int8>(mutableTypedPointer)
//}

enum Kind {
    case wolf
    case fox
    case dog
    case sheep
}

struct Animal {
    private var a: Int = 1       //8 byte
    var b: String = "animal"     //24 byte
    var c: Kind = .wolf          //1 byte
    var d: String?               //25 byte
    var e: Int8 = 8              //1 byte
    
    //返回指向 Animal 实例头部的指针
    mutating func headPointerOfStruct() -> UnsafeMutablePointer<Int8> {
        return withUnsafeMutablePointer(to: &self) {
            return UnsafeMutableRawPointer($0).bindMemory(to: Int8.self, capacity: MemoryLayout<Animal>.stride)
        }
    }
        
        func printA() {
            print("Animal a:\(a)")
        }
}
