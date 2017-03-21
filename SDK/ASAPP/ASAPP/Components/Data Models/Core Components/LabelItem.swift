//
//  LabelItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class LabelItem: NSObject, Component {
    
    enum JSONKey: String {
        case text = "text"
    }
    
    // MARK: Default
    
    static let defaultColor = UIColor.darkText
    
    // MARK: Properties
    
    let text: String
 
    // MARK: Component Properties
        
    let id: String?
    
    let style: ComponentStyle
    
    // MARK: Init
    
    init(text: String, id: String?, style: ComponentStyle) {
        self.text = text
        self.id = id
        self.style = style
        super.init()
    }
    
    // MARK:- Component Parsing

    static func make(with content: Any?,
                     id: String?,
                     style: ComponentStyle) -> Component? {
        guard let content = content as? [String : Any] else {
            return nil
        }
        guard let text = content[JSONKey.text.rawValue] as? String else {
            DebugLog.w(caller: self, "Missing text: \(content)")
            return nil
        }
        return LabelItem(text: text, id: id, style: style)
    }
}
