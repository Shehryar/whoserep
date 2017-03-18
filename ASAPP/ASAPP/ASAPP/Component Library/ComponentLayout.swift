//
//  ComponentLayout.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentLayout: NSObject {
    
    let margin: UIEdgeInsets
    let padding: UIEdgeInsets
    
    init(margin: UIEdgeInsets = .zero,
         padding: UIEdgeInsets = .zero) {
        
        self.margin = margin
        self.padding = padding
        super.init()
    }
    
    // MARK: JSON
    
    class func fromJSON(_ json: [String : AnyObject]?) -> ComponentLayout {
        guard let json = json else {
            return ComponentLayout()
        }
        
        let margin = UIEdgeInsets.fromJSON(json["margin"] as? [String : AnyObject],
                                           defaultValues: .zero)
        
        let padding = UIEdgeInsets.fromJSON(json["padding"] as? [String : AnyObject],
                                            defaultValues: .zero)
        
        
        return ComponentLayout(margin: margin, padding: padding)
    }
}

extension UIEdgeInsets {
    
    static func fromJSON(_ json: [String : AnyObject]?,
                         defaultValues: UIEdgeInsets = .zero) -> UIEdgeInsets {
        guard let json = json else {
            return defaultValues
        }
        
        var insets = defaultValues
        if let left = json["left"] as? CGFloat {
            insets.left = left
        }
        if let top = json["top"] as? CGFloat {
            insets.top = top
        }
        if let right = json["right"] as? CGFloat {
            insets.right = right
        }
        if let bottom = json["bottom"] as? CGFloat {
            insets.bottom = bottom
        }
        return insets
    }
}
