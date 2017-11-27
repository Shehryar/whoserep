//
//  ArrayExtensions.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 11/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

extension Array {
    func union<T>(_ other: [T]) -> [T] {
        let set = NSOrderedSet(array: other)
        let all = NSMutableOrderedSet(array: self)
        all.union(set)
        return all.array as! [T]
    }
}
