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

protocol ComponentViewContentHandler: class {
    
    func componentView(_ componentView: ComponentView,
                       didUpdateContent value: Any?,
                       requiresLayoutUpdate: Bool)
}

protocol ComponentView: UpdatableFrames {
    
    var component: Component? { get set }
    
    var nestedComponentViews: [ComponentView]? { get }
    
    var interactionHandler: InteractionHandler? { get set }
    
    var contentHandler: ComponentViewContentHandler? { get set }
    
    // Handled by the extensions below
    
    var view: UIView { get }
    
    func updateHandlersForNestedComponentViews()
}

extension ComponentView where Self: UIView {
        
    var view: UIView {
        return self
    }
}

extension ComponentView where Self: Any {
    
    func updateHandlersForNestedComponentViews() {
        
        guard let nestedComponentViews = nestedComponentViews else {
            return
        }
        
        for idx in nestedComponentViews.indices {
            var nestedComponentView = nestedComponentViews[idx]
            
            nestedComponentView.interactionHandler = interactionHandler
            nestedComponentView.contentHandler = contentHandler
        }
    }
}

// MARK: Enumerating Children

extension ComponentView where Self: Any {
    
    // Return true to stop
    func enumerateNestedComponentViews(block: ((_ childView: ComponentView) -> Void)) {
        if let nestedComponentViews = nestedComponentViews {
            for nestedView in nestedComponentViews {
                block(nestedView)
                nestedView.enumerateNestedComponentViews(block: block)
            }
        }
    }
}
