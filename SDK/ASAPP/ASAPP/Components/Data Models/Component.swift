//
//  Component.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class Component: NSObject {
    
    // MARK:- Properties
    
    var viewClass: UIView.Type {
        assert(false, "Subclass '\(String(describing: type(of: self)))' must override variable 'viewClass: ComponentView.Type'!")
        return ButtonView.self
    }
    
    let id: String?
    
    let name: String?
    
    var value: Any?
    
    let style: ComponentStyle
    
    /// Subclasses should override this, if necessary
    var nestedComponents: [Component]? {
        return nil
    }
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        self.id = id
        self.name = name
        self.value = value
        self.style = style
        super.init()
    }
    
    // MARK: View Generation
    
    func createView() -> ComponentView? {
        var view = viewClass.init() as? ComponentView
        view?.component = self
        return view
    }
    
    // MARK: Finding a Component

    func findComponent(with componentId: String) -> Component? {
        if id == componentId {
            return self
        }
        
        if let nestedComponents = nestedComponents {
            for nestedComponent in nestedComponents {
                if let foundComponent = nestedComponent.findComponent(with: componentId) {
                    return foundComponent
                }
            }
        }
        
        return nil
    }
    
    func findNameValue(for componentId: String) -> (String?, Any?) {
        guard let component = findComponent(with: componentId) else {
            return (nil, nil)
        }
        return (component.name, component.value)
    }
    
    func getData(for componentIds: [String]?) -> [String : Any] {
        var data = [String : Any]()
        guard let componentIds = componentIds else {
            return data
        }
        
        for componentId in componentIds {
            let (name, value) = findNameValue(for: componentId)
            if let name = name, let value = value {
                data[name] = value
            }
        }
        return data
    }
}
