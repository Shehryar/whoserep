//
//  DictionaryExtensions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/18/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

extension Dictionary {
    mutating func add(_ other: Dictionary?) {
        guard let other = other else {
            return
        }
        
        for (key, value) in other {
            updateValue(value, forKey: key)
        }
    }
    
    func adding(_ other: Dictionary?) -> Dictionary {
        var result = self
        
        guard let other = other else {
            return result
        }
        
        for (key, value) in other {
            result.updateValue(value, forKey: key)
        }
        
        return result
    }
    
    func with(_ other: Dictionary?) -> Dictionary {
        var dict = Dictionary()
        for (key, value) in self {
            dict.updateValue(value, forKey: key)
        }
        dict.add(other)
        
        return dict
    }
}
