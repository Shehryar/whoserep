//
//  ComponentFactory.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol Component {
    static func fromJSON(_ json: [String : AnyObject]) -> AnyObject
}

class ComponentFactory: NSObject {
    
    private static var componentClassMap = [String : Component]()
    
    class func registerComponentClass(_ componentClass: Component, withName name: String) {
        componentClassMap[name] = componentClass
    }
    
    class func getComponentClass(withName name: String) -> Component? {
        return componentClassMap[name]
    }
    
    class func getComponent(withName name: String, fromJSON json: [String : AnyObject]?) -> NSObject? {
        guard let json = json else {
            return nil
        }
        
        if let componentClass = getComponentClass(withName: name) {
//            return componentClass.self.fromJSON(json)
            
        }
        
        return nil
    }
}
