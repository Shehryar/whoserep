//
//  StringExtensions.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 6/13/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

extension String {
    var sdbmHashValue: Int {
        return unicodeScalars.map { $0.value }.reduce(0, { (result, current) -> Int in
            return Int(current)
                &+ (result << 6)
                &+ (result << 16)
                &- result
        })
    }
}
