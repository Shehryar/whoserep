//
//  ProgressBarItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ProgressBarItem: NSObject, Component {
    
    enum JSONKey: String {
        case fillPercentage = "fillPercentage"
    }
    
    // MARK: Defaults
    
    static let defaultColor = UIColor(red:0.447, green:0.788, blue:0.384, alpha:1.000)
    
    static let defaultBackgroundColor = UIColor(red:0.918, green:0.925, blue:0.937, alpha:1.000)
    
    static let defaultHeight: CGFloat = 10.0

    // MARK: Properties
    
    let fillPercentage: CGFloat /* 0...1 */
    
    // MARK: Component Properties
        
    let id: String?
    
    let style: ComponentStyle
    
    // MARK: Init
    
    init(fillPercentage: CGFloat,
         id: String?,
         style: ComponentStyle) {
        self.fillPercentage = fillPercentage
        self.id = id
        self.style = style
        super.init()
    }
    
    // MARK: Component Parsing
    
    static func make(with content: Any?,
                     id: String?,
                     style: ComponentStyle) -> Component? {
        guard let content = content as? [String : Any] else {
            return nil
        }
        
        let fillPercentage = content.float(for: JSONKey.fillPercentage.rawValue, defaultValue: 0)
        
        return ProgressBarItem(fillPercentage: fillPercentage,
                               id: id,
                               style: style)
    }
}
