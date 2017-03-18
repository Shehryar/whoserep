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
    
    static func view(with component: Component) -> ComponentView? {
        var componentView: ComponentView?
        switch component.type {
        case .icon:
            // TODO
            break
            
        case .label:
            // TODO
            break
            
        case .basicListItem:
            // TODO
            break
            
        case .stackView:
            // TODO
            break
        }
        componentView?.component = component
        
        return componentView
    }
}

// TODO: Think about reuse?
