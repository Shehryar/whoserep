//
//  StringExtensions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 11/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

extension String {
    func camelToSnakeCased() -> String {
        let regex = try? NSRegularExpression(pattern: "([a-z0-9])([A-Z])", options: [])
        let range = NSRange(location: 0, length: self.count)
        return (regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2") ?? self).lowercased()
    }
    
    func snakeToCamelCased() -> String {
        return self.split(separator: "_").enumerated().map { i, character in
            return i > 0 ? String(character).capitalized : String(character)
        }.joined()
    }
}
