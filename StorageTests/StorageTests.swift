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
        let value:StorageModel?  =  storage.object().filter("").sorted("").value(StorageModel.self)
        XCTAssertNotNil(value, "select object is null");
        XCTAssertNotNil(value?.name, "select object is null");
    }
    
    func testSelectObjectOfArray() {
        var storage = Storage()
        let value:[StorageModel]  =  storage.object().filter("").sorted("").valueOfArray(StorageModel.self)
        XCTAssertNotNil(value, "select object is null\(value)");
        XCTAssertNotNil(value.first, "select object is null \(String(describing: value.first))");
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
    
    func testInsertArrayStructModel() {
        var storageModel:StorageModel = StorageModel(name:"sd2", eMail: 2)
        storageModel.name = "王国仲"
        storageModel.eMail = 1
        
        var storage = Storage()
        let status = storage.addArray([storageModel])
        XCTAssertTrue(status, "insert object error \(status)")
    }
    
    func testCreateArrayStructModel() {
        let dic = [["name":"wangmaoling","eMail":123456],["name":"wangguozhong","eMail":123456]]
        
        var storage = Storage()
        let status = storage.create(StorageModel.self, value: dic)
        XCTAssertTrue(status, "insert object error \(status)")
    }
    
    func testCreateStructModel() {
        var storage = Storage()
        let status = storage.create(StorageModel.self, value: ["name":"wangmaoling","eMail":654321])
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
        let status = storage.update(storageModel)
        XCTAssertTrue(status, "update object error \(status)")
    }
    
    func testUpdateType() {
        let storage = Storage()
        let status = storage.update(StorageModel.self, ["name":"sdsd"]).execute()
        XCTAssertTrue(status, "update object error \(status)")
    }
    
    func testUpdateTypeOne() {
        let storage = Storage()
        let status = storage.update(StorageModel.self, ["name":"wangguozhong"]).filter(["eMail":123456]).execute()
        XCTAssertTrue(status, "update object error \(status)")
    }
    
    func testUpdateTypeTwo() {
        let storage = Storage()
        let status = storage.update(StorageModel.self, ["name":"wangguozhongs"]).filter(["eMail":123456]).limit(2).execute()
        XCTAssertTrue(status, "update object error \(status)")
    }
    
    func testUpdateTypeThree() {
        let storage = Storage()
        let status = storage.update(StorageModel.self, ["name":"wangguozhongss"]).filter(["eMail":123456]).sorted("name", ascending: true).limit(1).execute()
        XCTAssertTrue(status, "update object error \(status)")
    }
}

// MARK: - Delete object
extension StorageTests {
    func testDeleteObject() {
        var storageModel:StorageModel = StorageModel(name:"sd2", eMail: 2)
        storageModel.name = "王国仲"
        storageModel.eMail = 3
        
        var storage = Storage()
        let status = storage.delete(storageModel)
        XCTAssertTrue(status, "update object error \(status)")
    }
    
    func testDeleteOne() {
        var storage = Storage()
        let status = storage.delete(StorageModel.self).filter(["name":"sdsd"]).sorted("name").limit(1).execute()
        XCTAssertTrue(status, "update object error \(status)")
    }
    
    func testDeleteTwo() {
        var storage = Storage()
        let status = storage.delete(StorageModel.self).limit(1).execute()
        XCTAssertTrue(status, "update object error \(status)")
    }
    
    func testDeleteThree() {
        var storage = Storage()
        let status = storage.delete(StorageModel.self).sorted("name").limit(1).execute()
        XCTAssertTrue(status, "update object error \(status)")
    }
    
    func testDeleteAll() {
        var storage = Storage()
        let status = storage.deleteAll(StorageModel.self)
        XCTAssertTrue(status, "update object error \(status)")
    }
}
