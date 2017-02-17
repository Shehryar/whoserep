//
//  SRSLabelItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SRSLabelItem: NSObject {
    
    enum Alignment: String {
        case left = "left"
        case center = "center"
        case right = "right"
        
        func getNSTextAlignment() -> NSTextAlignment {
            switch self {
            case Alignment.left: return NSTextAlignment.left
            case Alignment.center: return NSTextAlignment.center
            case Alignment.right: return NSTextAlignment.right
            }
        }
    }
    
    // MARK: Properties
    
    let text: String
    
    var color: UIColor?
    
    var alignment: Alignment?
    
    // MARK: Init
    
    init(text: String) {
        self.text = text
        super.init()
    }
}

// MARK:- JSON Parsing

extension SRSLabelItem {
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> SRSLabelItem? {
        guard let json = json,
            let text = json["label"] as? String else {
                return nil
        }

        return SRSLabelItem(text: text)
    }
}
