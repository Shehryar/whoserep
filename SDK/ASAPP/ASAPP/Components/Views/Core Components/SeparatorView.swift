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
    
    fileprivate let separatorStroke: CGFloat = 1
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            separator.backgroundColor = separatorItem?.style.color ?? ASAPP.styles.primarySeparatorColor
            setNeedsLayout()
        }
    }
    
    var separatorItem: SeparatorItem? {
        return component as? SeparatorItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        separator.backgroundColor = ASAPP.styles.primarySeparatorColor
        addSubview(separator)
    }
    
    // MARK: Layout
    
    override func updateFrames() {
        guard let separatorItem = separatorItem else {
            return
        }
        let padding = separatorItem.style.padding
        
        let width: CGFloat
        let height: CGFloat
        switch separatorItem.separatorStyle {
        case .horizontal:
            width = bounds.width - padding.left - padding.right
            height = separatorStroke
            break
            
        case .vertical:
            width = separatorStroke
            height = bounds.height - padding.top - padding.bottom
            break
        }
        
        separator.frame = CGRect(x: padding.left, y: padding.top, width: width, height: height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let separatorItem = separatorItem else {
            return .zero
        }
        
        let padding = separatorItem.style.padding
        let width: CGFloat
        let height: CGFloat
        switch separatorItem.separatorStyle {
        case .horizontal:
            width = size.width < UIScreen.main.bounds.width ? size.width : separatorStroke + padding.top + padding.bottom
            height = separatorStroke + padding.top + padding.bottom
            break
            
        case .vertical:
            // Vertical separatofs need gravity=fill
            width = separatorStroke + padding.left + padding.right
            height = separatorStroke + padding.top + padding.bottom
            break
        }
        
        return CGSize(width: width, height: height)
    }
}
