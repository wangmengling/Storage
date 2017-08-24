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
    var name: String
    var eMail: Int?
//    var phome: String?
//    var nickName: String?
//    var password: String?
//    var passwords: Int?
//    var storageClassModel:StorageClassModel?
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
        let storageClassModel:StorageClassModel = StorageClassModel()
        storageClassModel.name = "wangmengling"
        storageClassModel.phone = "15828581089"
        
        var storageModel:StorageModel = StorageModel(name:"sd2", eMail: 2)
        storageModel.name = "王国仲"
        storageModel.eMail = 1
//        storageModel.storageClassModel = storageClassModel
        
        
        var stosss = Storage()
//        _ = stosss.add(storageModel, update: false)
        let array:Array<StorageModel>  =  stosss.object(StorageModel.self).filters("").sorted("").valueOfArray(StorageModel.self)
        print(array)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
