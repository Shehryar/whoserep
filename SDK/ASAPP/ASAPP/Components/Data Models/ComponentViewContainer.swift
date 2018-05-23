//
//  ComponentViewContainer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/21/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentViewContainer: NSObject {
    let root: Component
    let title: String?
    let styles: [String: Any]?
    let buttons: [QuickReply]?
    
    init(root: Component,
         title: String?,
         styles: [String: Any]?,
         buttons: [QuickReply]? = nil) {
        self.root = root
        self.title = title
        self.styles = styles
        self.buttons = buttons
        super.init()
    }
    
    func createView() -> ComponentView? {
        return root.createView()
    }
}

extension ComponentViewContainer {
    enum JSONKey: String {
        case root
        case styles
        case title
        case buttons
    }
    
    static func from(_ dict: [String: Any]?) -> ComponentViewContainer? {
        guard let dict = dict else {
            return nil
        }
        
        let title = dict.string(for: JSONKey.title.rawValue)
        let styles = dict[JSONKey.styles.rawValue] as? [String: Any]
        guard let root = ComponentFactory.component(with: dict[JSONKey.root.rawValue], styles: styles) else {
            return nil
        }
        
        var buttons: [QuickReply]?
        if let buttonDicts = dict.arrayOfDictionaries(for: JSONKey.buttons.rawValue) {
            buttons = QuickReply.arrayFromJSON(buttonDicts)
        }
        
        return ComponentViewContainer(root: root, title: title, styles: styles, buttons: buttons)
    }
}
