//
//  ComponentView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol InteractionHandler: class {
    
    func didTapButtonView(_ buttonView: ButtonView, with buttonItem: ButtonItem)
}

protocol ComponentView {
    
    var component: Component? { get set }
    
    weak var interactionHandler: InteractionHandler? { get set }
    
    var nestedComponentViews: [ComponentView]? { get }
    
    var view: UIView { get }
}

extension ComponentView {
    
    func getNestedComponentView(with componentId: String) -> ComponentView? {
        if component?.id == componentId {
            return self
        }
        
        guard let subviews = nestedComponentViews else {
            return nil
        }
        
        for view in subviews {
            if view.component?.id == componentId {
                return view
            }
        }
        return nil
    }
    
    func getNameValue(for componentId: String) -> (String, Any)? {
        let nestedView =  getNestedComponentView(with: componentId)
        if let name = nestedView?.component?.name,
            let value = nestedView?.component?.value {
            return (name, value)
        }
        
        return nil
    }
}

extension ComponentView where Self: UIView {
        
    var view: UIView {
        return self
    }

    var nestedComponentViews: [ComponentView]? {
        guard subviews.count > 0 else {
            return nil
        }
        
        var nestedViews = [ComponentView]()
        for view in subviews {
            if let componentView = view as? ComponentView {
                nestedViews.append(componentView)
                if let nestedNestedViews = componentView.nestedComponentViews {
                    nestedViews.append(contentsOf: nestedNestedViews)
                }
            }
        }
        return nestedViews
    }
}
