//
//  ChatMessageCarousel.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/17/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class ChatMessageCarousel {
    let elements: [ComponentViewContainer]
    
    init(elements: [ComponentViewContainer]) {
        self.elements = elements
    }
    
    class func from(_ dict: [String: Any]?) -> ChatMessageCarousel? {
        guard let dict = dict else {
            return nil
        }
        
        var elements: [ComponentViewContainer] = []
        guard let elementDicts = dict.arrayOfDictionaries(for: "elements") else {
            DebugLog.w(caller: self, "elements required: \(dict)")
            return nil
        }
        
        elements = elementDicts.map { ComponentViewContainer.from($0) }.compactMap { $0 }
        
        return ChatMessageCarousel(elements: elements)
    }
}
