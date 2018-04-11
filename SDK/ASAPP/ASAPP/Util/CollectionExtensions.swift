//
//  CollectionExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 3/14/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

extension Collection {
    func separate(_ predicate: (Iterator.Element) -> Bool) -> (matching: [Iterator.Element], notMatching: [Iterator.Element]) {
        var subsets: ([Iterator.Element], [Iterator.Element]) = ([], [])
        
        for element in self {
            if predicate(element) {
                subsets.0.append(element)
            } else {
                subsets.1.append(element)
            }
        }
        
        return subsets
    }
}
