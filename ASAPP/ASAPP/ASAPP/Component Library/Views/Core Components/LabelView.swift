//
//  LabelView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class LabelView: UIView, ComponentView {
    
    let label = UILabel()
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            if let labelItem = labelItem {
                label.text = labelItem.text
                label.textAlignment = labelItem.alignment
                label.textColor = labelItem.color
                label.numberOfLines = labelItem.numberOfLines
                label.font = ASAPP.styles.font(with: labelItem.fontWeight,
                                               size: labelItem.fontSize)
            } else {
                label.text = nil
            }
        }
    }
    
    var labelItem: LabelItem? {
        return component as? LabelItem
    }
    
    // MARK: Init
    
    func commonInit() {
        label.lineBreakMode = .byWordWrapping
        addSubview(label)
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
        guard let labelItem = labelItem else {
            return .zero
        }
        let padding = labelItem.layout.padding
        let maxWidth = size.width - padding.left - padding.right
        let height = ceil(label.sizeThatFits(CGSize(width: maxWidth, height: 0)).height)
        let top = height > 0 ? padding.top : 0
        return CGRect(x: padding.left, y: top, width: maxWidth, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame = getFrameThatFits(bounds.size)
        label.frame = frame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let labelItem = labelItem else {
            return .zero
        }
        
        let frame = getFrameThatFits(size)
        let height = frame.height > 0 ? frame.height + labelItem.layout.padding.bottom : 0
        
        return CGSize(width: size.width, height: height)
    }
}
