//
//  ArrayExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/21/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func withoutDuplicates() -> Array {
        var set = Set<Element>()
        var result: [Element] = []
        for item in self {
            if !set.contains(item) {
                set.insert(item)
                result.append(item)
            }
        }
        return result
    }
}
