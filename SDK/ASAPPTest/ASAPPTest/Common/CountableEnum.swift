//
//  CountableEnum.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 11/7/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

protocol CountableEnum {
    static var count: Int { get }
}

extension CountableEnum where Self: RawRepresentable, Self.RawValue == Int {
    static var count: Int {
        var count = 0
        while Self(rawValue: count) != nil {
            count += 1
        }
        return count
    }
}
