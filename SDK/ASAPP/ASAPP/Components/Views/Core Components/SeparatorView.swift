//
//  SeparatorView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SeparatorView: BaseComponentView {

    // MARK: Properties
    
    let separator = UIView()
    
    private let separatorStroke: CGFloat = 1
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            separator.backgroundColor = separatorItem?.style.color ?? ASAPP.styles.colors.separatorPrimary
            setNeedsLayout()
        }
    }
    
    var separatorItem: SeparatorItem? {
        return component as? SeparatorItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        separator.backgroundColor = ASAPP.styles.colors.separatorPrimary
        addSubview(separator)
        isAccessibilityElement = false
    }
    
    // MARK: Layout
    
    func frameThatFits(_ size: CGSize) -> (CGRect, CGSize) {
        guard let separatorItem = separatorItem else {
            return (.zero, .zero)
        }
        let style = separatorItem.style
        let padding = style.padding
    
        var contentSize = CGSize.zero
        let left: CGFloat
        let top: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        switch separatorItem.separatorStyle {
        case .horizontal:
            contentSize.width = min(UIScreen.main.bounds.width, size.width)
            let defaultWidth = contentSize.width - padding.left - padding.right
            if style.width > 0 {
                width = style.width
            } else {
                width = defaultWidth
            }
            left = padding.left + floor((defaultWidth - width) / 2.0)
            
            if style.height > 0 {
                height = style.height
            } else {
                height = separatorStroke
            }
            contentSize.height = height + padding.top + padding.bottom
            top = padding.top
            
        case .vertical:
            if style.width > 0 {
                width = style.width
            } else {
                width = separatorStroke
            }
            contentSize.width = width + padding.left + padding.right
            left = padding.left
            
            contentSize.height = min(UIScreen.main.bounds.height, size.height)
            let defaultHeight = contentSize.height - padding.top - padding.bottom
            if style.height > 0 {
                height = style.height
            } else {
                height = defaultHeight
            }
            top = padding.top + floor((defaultHeight - height) / 2.0)
        }
        
        let frame = CGRect(x: left, y: top, width: width, height: height)
        return (frame, contentSize)
    }
    
    override func updateFrames() {
        super.updateFrames()
        
        (separator.frame, _) = frameThatFits(bounds.size)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard separatorItem != nil else {
            return .zero
        }
        let (_, contentSize) = frameThatFits(size)
        return contentSize
    }
}
