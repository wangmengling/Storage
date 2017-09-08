//
//  StorageTypeNestedTests.swift
//  StorageTests
//
//  Created by utouu-imac on 2017/9/8.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import XCTest
@testable import Storage
struct StorageTypeNestedModel:Codable {
    var storageModel:StorageModel?
    var title:String?
    var content:String?
    var time:Int?
}

class StorageTypeNestedTests: XCTestCase {
    
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
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testTypeNestedIntertModel() {
        var storageModel:StorageModel = StorageModel()
        storageModel.name = "王国仲"
        storageModel.eMail = 424080998
        
        var storageTypeNestedModel:StorageTypeNestedModel = StorageTypeNestedModel()
        storageTypeNestedModel.content = "mutale type nested"
        storageTypeNestedModel.title = "type nested"
        storageTypeNestedModel.time = Int(NSDate().timeIntervalSinceNow / 1000)
        
        var storage = Storage()
        let status = storage.add(storageTypeNestedModel)
        XCTAssertTrue(status, "insert object error \(status)")
    }
}
