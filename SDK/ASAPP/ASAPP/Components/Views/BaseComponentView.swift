//
//  BaseComponentView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BaseComponentView: UIView, ComponentView, ComponentStyleable {

    static let defaultBackgroundColor = UIColor.clear
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            if let component = component {
                applyStyle(component.style)
            }
        }
    }

    var nestedComponentViews: [ComponentView]? {
        return nil
    }
    
    weak var interactionHandler: InteractionHandler? {
        didSet {
            updateHandlersForNestedComponentViews()
        }
    }
    
    weak var contentHandler: ComponentViewContentHandler? {
        didSet {
            updateHandlersForNestedComponentViews()
        }
    }
    
    // MARK: Init
    
    func commonInit() {
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: UpdatableFrames
    
    func updateFrames() {
        // Subviews should override
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
}
