//
//  SliderItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SliderItem: Component {
    
    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case label = "label"
        case max = "max"
        case min = "min"
    }
    
    // MARK:- Defaults
    
    static let defaultMinValue: CGFloat = 0
    
    static let defaultMaxValue: CGFloat = 100
    
    // MARK:- Properties
    
    let label: LabelItem?
    
    let minValue: CGFloat
    
    let maxValue: CGFloat
    
    // MARK:- Component Properties
    
    override var viewClass: UIView.Type {
        return SliderView.self
    }
    
    override var nestedComponents: [Component]? {
        if let label = label {
            return [label]
        }
        return nil
    }
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        
        self.label = ComponentFactory.component(with: content?[JSONKey.label.rawValue],
                                                styles: styles) as? LabelItem
        self.minValue = content?.float(for: JSONKey.min.rawValue)
            ?? SliderItem.defaultMinValue
        self.maxValue = content?.float(for: JSONKey.max.rawValue)
        ?? SliderItem.defaultMaxValue
        
        super.init(id: id,
                   name: name,
                   value: value,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
