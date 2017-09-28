//
//  ComponentCardView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentCardView: UIView {

    var component: Component? {
        didSet {
            componentView = component?.createView()
            componentView?.interactionHandler = interactionHandler
            componentView?.contentHandler = contentHandler
            setNeedsLayout()
        }
    }
    
    var borderDisabled: Bool = false {
        didSet {
            updateBorder()
        }
    }
    
    var interactionHandler: InteractionHandler? {
        didSet {
            componentView?.interactionHandler = interactionHandler
        }
    }
    
    var contentHandler: ComponentViewContentHandler? {
        didSet {
            componentView?.contentHandler = contentHandler
        }
    }
    
    private(set) var componentView: ComponentView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            
            componentView?.interactionHandler = interactionHandler
            if let componentView = componentView {
                addSubview(componentView.view)
            }
            setNeedsLayout()
        }
    }
    
    // MARK: Initialization
    
    func commonInit() {
        
        updateBorder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    deinit {
        componentView?.interactionHandler = nil
    }
    
    // MAKR: Utility
    
    func updateBorder() {
        if borderDisabled {
            clipsToBounds = false
            backgroundColor = UIColor.clear
            layer.borderColor = nil
            layer.borderWidth = 0
        } else {
            clipsToBounds = true
            backgroundColor = ASAPP.styles.colors.backgroundPrimary
            layer.borderColor = ASAPP.styles.colors.separatorPrimary.cgColor
            layer.borderWidth = ASAPP.styles.separatorStrokeWidth
            layer.cornerRadius = 5
        }
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        componentView?.view.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let componentView = componentView else {
            return .zero
        }
        
        let fittedSize = componentView.view.sizeThatFits(size)
            
        return fittedSize
    }
}
