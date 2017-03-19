//
//  SeparatorView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SeparatorView: UIView, ComponentView {

    // MARK: Properties
    
    let separator = UIView()
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            if let separatorItem = separatorItem {
                separator.backgroundColor = separatorItem.color ?? ASAPP.styles.separatorColor1
                setNeedsLayout()
            }
        }
    }
    
    var separatorItem: SeparatorItem? {
        return component as? SeparatorItem
    }
    
    // MARK: Init
    
    func commonInit() {
        separator.backgroundColor = ASAPP.styles.separatorColor1
        addSubview(separator)
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
    
    func getFrameThatFits(_ size: CGSize) -> CGRect {
        guard let component = component else {
            return .zero
        }
        
        let top = component.layout.padding.top
        let left = component.layout.padding.left
        let width = size.width - left - component.layout.padding.right
        let frame = CGRect(x: left, y: top, width: width, height: 1)
        
        return frame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame = getFrameThatFits(bounds.size)
        separator.frame = frame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let paddingBottom = component?.layout.padding.bottom ?? 0
        let frame = getFrameThatFits(size)
        
        return CGSize(width: size.width, height: frame.maxY + paddingBottom)
    }
}
