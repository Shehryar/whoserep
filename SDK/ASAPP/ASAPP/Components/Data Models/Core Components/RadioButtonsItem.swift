//
//  RadioButtonsItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonsItem: Component {

    // MARK:- JSON Keys
    
    enum JSONKey: String {
        case buttons = "buttons"
    }
    
    // MARK:- Properties
    
    override var viewClass: UIView.Type {
        return RadioButtonsView.self
    }
    
    let buttons: [RadioButtonItem]
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        var buttons = [RadioButtonItem]()
        if let buttonsJSON = content?[JSONKey.buttons.rawValue] as? [[String : Any]] {
            for buttonJSON in buttonsJSON {
                if let buttonItem = ComponentFactory.component(with: buttonJSON, styles: styles) as? RadioButtonItem {
                    buttons.append(buttonItem)
                }
            }
        }
        guard !buttons.isEmpty else {
            DebugLog.w(caller: RadioButtonsItem.self, "Empty buttons. Returning nil: \(content)")
            return nil
        }
        
        self.buttons = buttons
        
        super.init(id: id,
                   name: name,
                   value: value,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
