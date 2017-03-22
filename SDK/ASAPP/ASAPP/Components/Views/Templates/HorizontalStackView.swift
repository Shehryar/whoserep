//
//  HorizontalStackView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class HorizontalStackView: UIView, ComponentView {

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
            setNeedsLayout()
        }
    }
    
    var stackViewItem: StackViewItem? {
        return component as? StackViewItem
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
        guard let component = component else {
            return ([CGRect](), .zero)
        }
        let padding = component.style.padding
        let contentWidth = size.width - padding.left - padding.right
        let contentFrame = CGRect(x: padding.left, y: padding.top,
                                  width: contentWidth, height: 0)
        
        let layoutInfo = ComponentLayoutEngine.getHorizontalLayout(for: subviews, inside: contentFrame)
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
}
