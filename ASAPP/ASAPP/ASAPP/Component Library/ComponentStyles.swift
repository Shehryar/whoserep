//
//  ComponentStyles.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum JSONKey {
    static let paddingLeft = "padding_left"
    static let paddingTop = "padding_top"
    static let paddingRight = "padding_right"
    static let paddingBottom = "padding_bottom"
}

class ComponentStyles: NSObject {
    
    var padding = UIEdgeInsets.zero
    
}

// MARK: JSON

extension ComponentStyles {
    
    class func fromJSON(_ json: [String : AnyObject]?) -> ComponentStyles? {
        guard let json = json else {
            return nil
        }
        
        var padding = UIEdgeInsets.zero
        if let paddingLeft = json[JSONKey.paddingLeft] as? CGFloat {
            padding.left = paddingLeft
        }
        if let paddingTop = json[JSONKey.paddingTop] as? CGFloat {
            padding.top = paddingTop
        }
        if let paddingRight = json[JSONKey.paddingRight] as? CGFloat {
            padding.right = paddingRight
        }
        if let paddingBottom = json[JSONKey.paddingBottom] as? CGFloat {
            padding.bottom = paddingBottom
        }
        
        
        return nil
    }
}
