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
        label.numberOfLines = 0
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
        
        var fitToSize = size
        if fitToSize.width == 0 {
            fitToSize.width = CGFloat.greatestFiniteMagnitude
        }
        if fitToSize.height == 0 {
            fitToSize.height = CGFloat.greatestFiniteMagnitude
        }
        
        let padding = labelItem.style.padding
        fitToSize.width = max(0, fitToSize.width - padding.left - padding.right)
        fitToSize.height = max(0, fitToSize.height - padding.top - padding.bottom)
        
        var fittedSize = label.sizeThatFits(fitToSize)
        fittedSize.width = ceil(min(fitToSize.width, fittedSize.width))
        fittedSize.height = ceil(min(fitToSize.height, fittedSize.height))
        
        let top = fittedSize.height > 0 ? padding.top : 0
        let frame = CGRect(x: padding.left, y: top, width: fittedSize.width, height: fittedSize.height)
        return frame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let labelItem = labelItem {
            let padding = labelItem.style.padding
            label.frame = UIEdgeInsetsInsetRect(bounds, padding)
        } else {
            label.frame = .zero
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let labelItem = labelItem else {
            return .zero
        }
        
        let padding = labelItem.style.padding
        let frame = getFrameThatFits(size)
        let width = frame.width > 0 ? frame.maxX + padding.right : 0
        let height = frame.height > 0 ? frame.maxY + padding.bottom : 0
        
        return CGSize(width: width, height: height)
    }
}
