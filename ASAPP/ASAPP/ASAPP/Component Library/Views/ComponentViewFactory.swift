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
        /** Core Components **/
        case .button:
            break
            
        case .icon:
            break
            
        case .label:
            break
            
            
        /* Templates */
        case .basicListItem:
            break
            
        case .stackView:
            break
        }
        
        return componentView
    }
}

// TODO: Think about reuse?
