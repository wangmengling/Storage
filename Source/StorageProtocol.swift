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
