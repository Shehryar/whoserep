//
//  StackView_new.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class StackView_new: UIView, ComponentView {

    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            for subview in subviews {
                subview.removeFromSuperview()
            }
            
            if let stackViewItem = stackViewItem {
                for item in stackViewItem.items {
                    if let componentView = item.createView() {
                        addSubview(componentView.view)
                    }
                }
            }
            
            updateSubviewsWithInteractionHandler()
            
            setNeedsLayout()
        }
    }
    
    var stackViewItem: StackViewItem? {
        return component as? StackViewItem
    }
    
    weak var interactionHandler: InteractionHandler? {
        didSet {
            updateSubviewsWithInteractionHandler()
        }
    }

    // MARK: Init
    
    func commonInit() {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Layout
    
    func getFramesAndContentSize(for size: CGSize) -> ([CGRect], CGSize) {
        guard let stackViewItem = stackViewItem else {
            return ([CGRect](), .zero)
        }
        var fitToSize = size
        if fitToSize.height == 0 {
            fitToSize.height = .greatestFiniteMagnitude
        }
        if fitToSize.width == 0 {
            fitToSize.width = .greatestFiniteMagnitude
        }
    
        let padding = stackViewItem.style.padding
        let contentFrame = CGRect(x: padding.left,
                                  y: padding.top,
                                  width: fitToSize.width - padding.left - padding.right,
                                  height: fitToSize.height - padding.top - padding.bottom)
        let layoutInfo: ComponentLayoutEngine.LayoutInfo
        if stackViewItem.orientation == .vertical {
            layoutInfo = ComponentLayoutEngine.getVerticalLayout(for: subviews, inside: contentFrame)
        } else {
            layoutInfo = ComponentLayoutEngine.getHorizontalLayout(for: subviews, inside: contentFrame)
        }
        
        var contentSize = CGSize.zero
        if layoutInfo.maxX > 0 && layoutInfo.maxY > 0 {
            contentSize = CGSize(width: layoutInfo.maxX + padding.right,
                                 height: layoutInfo.maxY + padding.bottom)
        }
        
        return (layoutInfo.frames, contentSize)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (frames, _) = getFramesAndContentSize(for: bounds.size)
        if frames.count == subviews.count {
            for (idx, subview) in subviews.enumerated() {
                subview.frame = frames[idx]
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (_, contentSize) = getFramesAndContentSize(for: size)
        
        return contentSize
    }
    
    // MARK: Utility
    
    func updateSubviewsWithInteractionHandler() {
        for (idx, _) in subviews.enumerated() {
            var view = subviews[idx] as? ComponentView
            view?.interactionHandler = self.interactionHandler
        }
    }
}
