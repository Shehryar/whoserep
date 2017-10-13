//
//  StackViewItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class StackViewItem: Component {
    
    // MARK: - JSON Keys
    
    enum JSONKey: String {
        case items
        case orientation
    }
    
    enum Orientation: String {
        case vertical
        case horizontal
        
        static func from(_ string: String?, defaultValue: Orientation) -> Orientation {
            guard let string = string,
                let orientation = Orientation(rawValue: string) else {
                    return defaultValue
            }
            return orientation
        }
        
    }
    
    // MARK: - Properties
    
    let items: [Component]
    
    let orientation: Orientation
    
    // MARK: - Component Properties
    
    override var viewClass: UIView.Type {
        return StackView.self
    }
    
    override var nestedComponents: [Component]? {
        return items
    }
  
    // MARK: - Init
    
    init?(orientation: Orientation, items: [Component], style: ComponentStyle) {
        self.orientation = orientation
        self.items = items
        super.init(style: style)
    }
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String : Any]? = nil,
                   content: [String : Any]? = nil) {
        
        guard let itemsJSON = content?[JSONKey.items.rawValue] as? [[String : Any]] else {
            DebugLog.w(caller: StackViewItem.self, "Missing items json. Returning nil:\n\(String(describing: content))")
            return nil
        }
        
        var items = [Component]()
        for itemJSON in itemsJSON {
            if let component = ComponentFactory.component(with: itemJSON, styles: styles) {
                items.append(component)
            }
        }
        guard !items.isEmpty else {
            DebugLog.w(caller: StackViewItem.self, "Empty items json. Returning nil:\n\(String(describing: content))")
            return nil
        }
        self.items = items
        self.orientation = Orientation.from(content?.string(for: JSONKey.orientation.rawValue),
                                            defaultValue: .vertical)
                
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
