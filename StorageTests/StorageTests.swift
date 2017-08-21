//
//  StorageTests.swift
//  StorageTests
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import XCTest
@testable import Storage

struct StorageModel {
    var name: String?
    var eMail: Int?
//    var phome: String?
//    var nickName: String?
//    var password: String?
//    var passwords: Int?
}

extension StorageModel:StorageProtocol {
    func primaryKey() -> String {
        return "name"
    }
}

class StorageClassModel: NSObject {
    var name: String?
    var eMail: Int?
    var phone: String?
}

class StorageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var storageModel:StorageModel = StorageModel()
        storageModel.name = "王国仲"
        storageModel.eMail = 1;
//        var storagePointer:StoragePointer   = StoragePointer()
////        storagePointer.deCodeable(&storageModel)
//        let pointer = storagePointer.headPointerOfStruct(&storageModel)
//        print(pointer,pointer.pointee)
//        storagePointer.s(&storageModel)
//        storagePointer.he
//        _ = Storage().add(storageModel)
//        let m = Mirror(reflecting: storageModel)
//        m.children.m
//        print(m.children)
//        let mirror = StorageMirror(reflecting: &storageModel);
//        print(mirror.numberOfFields ?? 0)
//        print(mirror.fieldNames)
//        print(mirror.fieldTypes!)
        
//        for var type:Any.Type in mirror.fieldTypes! {
//            switch type {
//            case is Optional<String>.Type:
//                print(type)
//                break
//            case is Optional<Int>.Type:
//                print(type)
//                break
//            default:
//                print(type)
//                break
//            }
//        }
        
        var sto = Storage()
        sto.add(storageModel)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
