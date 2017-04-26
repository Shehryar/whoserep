//
//  ProgressBarItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ProgressBarItem: Component {
    
    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case fillPercentage = "fillPercentage"
    }
    
    // MARK:- Defaults
    
    static let defaultColor = UIColor(red:0.447, green:0.788, blue:0.384, alpha:1.000)
    
    static let defaultBackgroundColor = UIColor(red:0.918, green:0.925, blue:0.937, alpha:1.000)
    
    static let defaultHeight: CGFloat = 10.0

    static let defaultFillPercentage: CGFloat = 0.0
    
    // MARK:- Properties
    
    let fillPercentage: CGFloat /* 0...1 */
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return ProgressBarView.self
    }
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        self.fillPercentage = content?.float(for: JSONKey.fillPercentage.rawValue)
            ?? ProgressBarItem.defaultFillPercentage
        
        super.init(id: id,
                   name: name,
                   value: value,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
