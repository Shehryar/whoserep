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
        case .basicList:
            break
            
        case .basicListItem:
            break
            
        case .basicListSection:
            break
            
        case .titleButtonContainer:
            break
        }
        componentView?.component = component
        
        DebugLog.w(caller: self, "Unknown component: \(component)")
        return componentView
    }
}


// MARK:- ComponentView

protocol ComponentView {
    
    var component: Component? { get set }
}
