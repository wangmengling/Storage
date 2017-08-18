//
//  Storage.swift
//  Storage
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation

struct Storage: StorageProtocol {
    fileprivate var storageToSQLite = StorageToSQLite.shareInstance
}

extension Storage {
    mutating func add<T>(_ object:T?, update:Bool = false) -> Bool {
        guard let object:T = object else {
            return false
        }
        //创建数据库
        if !storageToSQLite.tableIsExists(object){
            _ = storageToSQLite.createTable(object)
        }
        //修改
        if update == true && storageToSQLite.count(object) > 0{
//            return storageToSQLite.update(object)
        }
//        return storageToSQLite.insert(object)
        return true
    }
}


extension Storage {
    fileprivate  func tableName(_ objects:Any) -> String{
        let objectsMirror = Mirror(reflecting: objects)
        return String(describing: objectsMirror.subjectType)
    }
}

