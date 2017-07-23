//
//  StorageTests.swift
//  StorageTests
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import XCTest
@testable import Storage

struct StorageModel:Codable {
    var name: String?
    var eMail: String?
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
//        _ = Storage().add(storageModel)
//        let m = Mirror(reflecting: storageModel)
//        m.children.m
//        print(m.children)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
