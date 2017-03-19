//
//  ComponentLayout.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum ContentAlignment: String {
    case start = "start"
    case center = "center"
    case end = "end"
    
    static func from(_ string: String?, defaultValue: ContentAlignment) -> ContentAlignment {
        guard let string = string,
            let alignment = ContentAlignment(rawValue: string) else {
                return defaultValue
        }
        return alignment
    }
}

// MARK:- ComponentLayout

class ComponentLayout: NSObject {
    
    let margin: UIEdgeInsets
    
    let padding: UIEdgeInsets
    
    let alignContent: ContentAlignment
    
    init(margin: UIEdgeInsets = .zero,
         padding: UIEdgeInsets = .zero,
         alignContent: ContentAlignment = .start) {
        self.margin = margin
        self.padding = padding
        self.alignContent = alignContent
        super.init()
    }
    
    // MARK: JSON
    
    class func fromJSON(_ json: Any?) -> ComponentLayout {
        guard let json = json as? [String : Any] else {
            return ComponentLayout()
        }
        
        let margin = UIEdgeInsets.fromJSON(json["margin"], defaultValues: .zero)
        let padding = UIEdgeInsets.fromJSON(json["padding"], defaultValues: .zero)
        
        let alignContent = ContentAlignment.from(json["align_content"] as? String,
                                                 defaultValue: .start)
        
        return ComponentLayout(margin: margin,
                               padding: padding,
                               alignContent: alignContent)
    }
}

extension UIEdgeInsets {
    
    static func fromJSON(_ json: Any?,
                         defaultValues: UIEdgeInsets = .zero) -> UIEdgeInsets {
        guard let json = json as? [String : Any] else {
            return defaultValues
        }
        
        var insets = defaultValues
        if let left = json["left"] as? Int {
            insets.left = CGFloat(left)
        }
        if let top = json["top"] as? Int {
            insets.top = CGFloat(top)
        }
        if let right = json["right"] as? Int {
            insets.right = CGFloat(right)
        }
        if let bottom = json["bottom"] as? Int {
            insets.bottom = CGFloat(bottom)
        }
        return insets
    }
}
