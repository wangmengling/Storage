//
//  StorageTests.swift
//  StorageTests
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import XCTest
@testable import Storage
class StorageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}


// MARK: - Select object
extension StorageTests {
    func testSelectObject() {
        var storage = Storage()
        let value:StorageModel?  =  storage.object(StorageModel.self).filters("").sorted("").value(StorageModel.self)
        XCTAssertNil(value, "select object is null");
        XCTAssertNil(value?.name, "select object is null");
    }
}

// MARK: - Insert object
extension StorageTests {
    func testInsertStructModel() {
        var storageModel:StorageModel = StorageModel(name:"sd2", eMail: 2)
        storageModel.name = "王国仲"
        storageModel.eMail = 1
        
        var storage = Storage()
        let status = storage.add(storageModel)
        XCTAssertTrue(status, "insert object error \(status)")
    }
}


// MARK: - Update object
extension StorageTests {
    func testUpdateObject() {
        var storageModel:StorageModel = StorageModel(name:"sd2", eMail: 2)
//        storageModel.name = "王国仲"
        storageModel.eMail = 3
        
        var storage = Storage()
        let status = storage.add(storageModel, update: true)
        XCTAssertTrue(status, "update object error \(status)")
    }
}

// MARK: - Delete object
extension StorageTests {
    func testDeleteObject() {
        var storageModel:StorageModel = StorageModel(name:"sd2", eMail: 2)
        //        storageModel.name = "王国仲"
        storageModel.eMail = 3
        
        var storage = Storage()
        let status = storage.delete(storageModel)
        XCTAssertTrue(status, "update object error \(status)")
    }
    
    func testDeleteAll() {
        var storage = Storage()
        let status = storage.deleteAll(StorageModel.self)
        XCTAssertTrue(status, "update object error \(status)")
    }
}
