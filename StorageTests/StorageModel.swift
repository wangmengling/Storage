//
//  StorageModel.swift
//  StorageTests
//
//  Created by utouu-imac on 2017/8/25.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
@testable import Storage


/// swift struct model
struct StorageModel:Codable {
    var name: String?
    var eMail: Int?
}

extension StorageModel:StorageProtocol {
//    func primaryKey() -> String {
//        return "name"
//    }
}

/// swift class model
class StorageClassModel: StorageProtocol {
    var name: String?
    var eMail: Int?
    var phone: String?
    required init() {
        
    }
}
