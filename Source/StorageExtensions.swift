//
//  StorageExtensions.swift
//  Storage
//
//  Created by jackWang on 2017/7/7.
//  Copyright © 2017年 jackWang. All rights reserved.
//

import Foundation
extension String {
    func positionOf(_ sub:String)->Int {
        var pos = -1
        if let range = self.range(of: sub) {
            if !range.isEmpty {
                pos = self.distance(from: self.startIndex, to: range.lowerBound)
            }
        }
        return pos
    }
    
    func subString(_ start:Int, length:Int = -1)->String {
        var len = length
        if len == -1 {
            len = self.count - start
        }
        let st = self.index(startIndex, offsetBy: start)
        //let en = <#T##String.CharacterView corresponding to `st`##String.CharacterView#>.index(st, offsetBy: len)
        let en = self.index(st, offsetBy: len)
        let range = st ..< en
        return self.substring(with: range)
    }
}
