//
//  BidirectionalCollectionExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 8/29/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

extension BidirectionalCollection {
    // coming soon in Swift 4.2
    public func last(
        where predicate: (Element) throws -> Bool
    ) rethrows -> Element? {
        return try lastIndex(where: predicate).map { self[$0] }
    }
    
    // coming soon in Swift 4.2
    public func lastIndex(
        where predicate: (Element) throws -> Bool
    ) rethrows -> Index? {
        var i = endIndex
        while i != startIndex {
            formIndex(before: &i)
            if try predicate(self[i]) {
                return i
            }
        }
        return nil
    }
}
