//
//  CapitalizationType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum CapitalizationType: String {
    case characters
    case none // Default
    case sentences
    case words
    
    func type() -> UITextAutocapitalizationType {
        switch self {
        case .characters: return .allCharacters
        case .none: return .none
        case .sentences: return .sentences
        case .words: return .words
        }
    }
    
    static func from(_ value: Any?) -> CapitalizationType? {
        guard let value = value as? String else {
            return nil
        }
        return CapitalizationType(rawValue: value)
    }
}

// MARK:- Dictionary Extension

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    
    func capitalizationType(for key: String) -> CapitalizationType? {
        return CapitalizationType.from(self[key as! Key] as? String)
    }
}
