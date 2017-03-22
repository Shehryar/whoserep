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
            componentView?.interactionHandler = self
            setNeedsLayout()
        }
    }
    
    fileprivate(set) var componentView: ComponentView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            
            componentView?.interactionHandler = self
            if let componentView = componentView {
                addSubview(componentView.view)
            }
            setNeedsLayout()
        }
    }
    
    // MARK: Initialization
    
    func commonInit() {
        clipsToBounds = true
        backgroundColor = ASAPP.styles.backgroundColor1
        layer.borderColor = ASAPP.styles.separatorColor2.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
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

extension ComponentCardView: InteractionHandler {
    
    func didTapButtonView(_ buttonView: ButtonView, with component: Component) {
        print("Got tap")
        
        
    }
}
