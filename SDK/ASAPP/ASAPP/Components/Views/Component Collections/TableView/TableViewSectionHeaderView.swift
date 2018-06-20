//
//  TableViewSectionHeaderView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TableViewSectionHeaderView: UIView, ComponentView {

    private(set) var componentView: ComponentView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            
            componentView?.interactionHandler = interactionHandler
            componentView?.contentHandler = contentHandler
            if let componentView = componentView {
                addSubview(componentView.view)
            }
            setNeedsLayout()
        }
    }
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            componentView = component?.createView()
        }
    }
    
    var nestedComponentViews: [ComponentView]? {
        if let componentView = componentView {
            return [componentView]
        }
        return nil
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
    
    // MARK: Init
    
    deinit {
        componentView?.interactionHandler = nil
        componentView?.contentHandler = nil
    }
    
    // MARK: Layout
    
    func willUpdateFrames() {}
    
    func updateFrames() {
        let margin = component?.style.margin ?? .zero
        componentView?.view.frame = UIEdgeInsetsInsetRect(bounds, margin)
    }
    
    func didUpdateFrames() {}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let componentView = componentView else {
            return .zero
        }
        
        let margin = component?.style.margin ?? .zero
        var maxWidth = size.width > 0 ? size.width : CGFloat.greatestFiniteMagnitude
        maxWidth -= margin.left + margin.right
        
        var maxHeight = size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude
        maxHeight -= margin.top + margin.bottom
        
        guard maxWidth > 0 && maxHeight > 0 else {
            return .zero
        }
        
        var fittedSize = componentView.view.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
        fittedSize.width = ceil(fittedSize.width)
        fittedSize.height = ceil(fittedSize.height)
        return fittedSize
    }
}
