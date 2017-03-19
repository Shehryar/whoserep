//
//  DemoComponents.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum DemoComponent: String {
    case stackView = "demo_stack_view"
}

class DemoComponents: NSObject {
    
    class func getComponent(for demoComponent: DemoComponent) -> Component? {
        guard let json =  DemoUtils.jsonObjectForFile(demoComponent.rawValue) else {
            DebugLog.w(caller: self, "Unable to find json file: \(demoComponent.rawValue)")
            return nil
        }
        
        guard let component = ComponentFactory.component(with: json) else {
            DebugLog.w(caller: self, "Unable to create demo \(demoComponent) json:\n\(json)")
            return nil
        }
        
        return component
    }
    
    class func getComponentView(for demoComponent: DemoComponent) -> ComponentView? {
        guard let component = getComponent(for: demoComponent) else {
            return nil
        }
        
        return ComponentViewFactory.view(withComponent: component)
    }
}
