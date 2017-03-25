//
//  ComponentViewContainer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/21/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentViewContainer: NSObject {
    
    enum JSONKey: String {
        case actions = "actions"
        case body = "body"
        case styles = "styles"
        case title = "title"
    }
    
    // MARK:- Properties
    
    let root: Component
    
    let title: String?
    
    let styles: [String : Any]?
    
    
    // MARK:- Init
    
    init(root: Component,
         title: String?,
         styles: [String : Any]?) {
        self.root = root
        self.title = title
        self.styles = styles
        super.init()
    }
    
    // MARK:- Instance Methods
    
    func createView() -> ComponentView? {
        return root.createView()
    }
}

// MARK:- JSON Parsing

extension ComponentViewContainer {
    
    static func from(_ json: Any?) -> ComponentViewContainer? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        
        let title = json.string(for: JSONKey.title.rawValue)
        let styles = json[JSONKey.styles.rawValue] as? [String : Any]
        guard let root = ComponentFactory.component(with: json[JSONKey.body.rawValue], styles: styles) else {
            return nil
        }
        
        return ComponentViewContainer(root: root,
                                      title: title,
                                      styles: styles)
    }
}
