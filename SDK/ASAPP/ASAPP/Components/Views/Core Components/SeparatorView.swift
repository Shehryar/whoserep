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
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            separator.backgroundColor = separatorItem?.style.color ?? SeparatorItem.defaultColor
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
    
    func getFrameThatFits(_ size: CGSize) -> CGRect {
        guard let component = component else {
            return .zero
        }
        
        let top = component.style.padding.top
        let left = component.style.padding.left
        let width = size.width - left - component.style.padding.right
        let frame = CGRect(x: left, y: top, width: width, height: 1)
        
        return frame
    }
    
    override func updateFrames() {
        let frame = getFrameThatFits(bounds.size)
        separator.frame = frame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let paddingBottom = component?.style.padding.bottom ?? 0
        let frame = getFrameThatFits(size)
        
        return CGSize(width: size.width, height: frame.maxY + paddingBottom)
    }
}
