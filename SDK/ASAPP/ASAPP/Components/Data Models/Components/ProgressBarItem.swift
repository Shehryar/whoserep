//
//  ProgressBarItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ProgressBarItem: Component {
    
    // MARK: - JSON Keys
    
    enum JSONKey: String {
        case fillPercentage
    }
    
    // MARK: - Defaults
    
    static let defaultHeight: CGFloat = 10.0

    static let defaultFillPercentage: CGFloat = 0.0
    
    // MARK: - Properties
    
    let fillPercentage: CGFloat /* 0...1 */
    
    // MARK: - Component Properties
    
    override var viewClass: UIView.Type {
        return ProgressBarView.self
    }
    
    // MARK: - Init
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String : Any]? = nil,
                   content: [String : Any]? = nil) {
        self.fillPercentage = content?.float(for: JSONKey.fillPercentage.rawValue)
            ?? ProgressBarItem.defaultFillPercentage
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
