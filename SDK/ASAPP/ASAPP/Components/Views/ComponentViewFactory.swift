//
//  ComponentViewFactory.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- ComponentViewFactory

enum ComponentViewFactory {
    
    static func view(withComponent component: Component) -> ComponentView? {
        var componentView: ComponentView?
        switch component.type {
        /** Core Components **/
        case .button:
            componentView = ButtonView()
            break
            
        case .icon:
            componentView = IconView()
            break
            
        case .label:
            componentView = LabelView()
            break
            
        case .separator:
            componentView = SeparatorView()
            break
            
            
        /* Templates */
        case .basicListItem:
            componentView = BasicListItemView()
            break
            
        case .stackView:
            if let stackViewItem = component as? StackViewItem,
                stackViewItem.orientation == .horizontal {
                componentView = HorizontalStackView()
            } else {
                componentView = StackView_new()
            }
            break
        }
        componentView?.component = component
        
        return componentView
    }
    
    static func view(withJSON json: Any?) -> ComponentView? {
        guard let component = ComponentFactory.component(with: json) else {
            return nil
        }
        return view(withComponent: component)
    }
}

// TODO: Think about reuse?
