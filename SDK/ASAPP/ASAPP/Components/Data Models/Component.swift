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
    
    let style: ComponentStyle
    
    let name: String?
    
    var value: Any?
    
    var isChecked: Bool?
    
    /// Subclasses should override this, if necessary
    var nestedComponents: [Component]? {
        return nil
    }
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   isChecked: Bool?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        self.id = id
        self.name = name
        self.value = value
        self.isChecked = isChecked
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
    
    func enumerateNestedComponents(_ block: ((_ nestedComponent: Component) -> Void)) {
        
        
        
        if let nestedComponents = nestedComponents {
            for component in nestedComponents {
                block(component)
                component.enumerateNestedComponents(block)
            }
        }
    }
    
    func getData() -> [String : Any] {
        var data = [String : Any]()
        
        func add(name: String, value: Any) {
            // Default - add the value under the name
            if !name.hasSuffix("[]") {
                data[name] = value
                return
            }
            
            // Add to, or create, an array
            if let valuesArray = data[name] as? [Any] {
                var mutableValuesArray = valuesArray
                mutableValuesArray.append(value)
                data[name] = mutableValuesArray
            } else {
                data[name] = [value]
            }
        }
        
        enumerateNestedComponents { (component) in
            DebugLog.d("in block")
            
            DebugLog.d("name=\(component.name ?? ""), value=\(component.value ?? "")")
            
            if let name = component.name,
                let value = component.value {
                
                if let checkbox = component as? CheckboxViewItem {
                    if checkbox.isChecked == true {
                        add(name: name, value: value)
                    }
                } else {
                    add(name: name, value: value)
                }
                
            }
        }
        DebugLog.d("after block")
        return data
    }
}
