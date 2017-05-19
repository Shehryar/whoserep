//
//  _RootComponentWrapperView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class _RootComponentWrapperView: BaseComponentView {

    var rootView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            var oldView = oldValue as? ComponentView
            oldView?.interactionHandler = nil
            oldView?.contentHandler = nil
            
            var currentView = rootView as? ComponentView
            currentView?.interactionHandler = interactionHandler
            currentView?.contentHandler = contentHandler
            
            if let rootView = rootView {
                addSubview(rootView)
                setNeedsLayout()
            }
        }
    }
    
    override var nestedComponentViews: [ComponentView]? {
        if let rootView = rootView as? ComponentView {
            return [rootView]
        }
        return nil
    }
    
    // MARK: Layout
    
    func getInsets() -> UIEdgeInsets {
        guard let component = component,
            let rootComponent = (rootView as? ComponentView)?.component else {
                return .zero
        }
        
        let padding = component.style.padding
        let margin = rootComponent.style.margin
        return UIEdgeInsets(top: margin.top + padding.top,
                            left: margin.left + padding.left,
                            bottom: padding.bottom + margin.bottom,
                            right: padding.right + margin.right)
    }
    
    override func updateFrames() {
        guard component != nil else {
            rootView?.frame = .zero
            return
        }
        
        rootView?.frame = UIEdgeInsetsInsetRect(bounds, getInsets())
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard component != nil,
            let rootView = rootView else {
                return .zero
        }
        
        let insets = getInsets()
        
        let maxWidth = (size.width > 0 ? size.width : CGFloat.greatestFiniteMagnitude) - insets.left - insets.right
        let maxHeight = (size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude) - insets.top - insets.bottom
        
        let contentSize = rootView.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
        let fittedSize = CGSize(width: contentSize.width + insets.left + insets.right,
                                height: contentSize.height + insets.top + insets.bottom)
        
        return fittedSize
    }

}
