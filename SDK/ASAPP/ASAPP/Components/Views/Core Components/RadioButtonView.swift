//
//  RadioButtonView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonView: BaseComponentView {

    var isSelected: Bool = false {
        didSet {
            
        }
    }
    
    let radioButtonView = UIView()
    
    let labelView = LabelView()
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            if let radioButtonItem = radioButtonItem {
                labelView.component = radioButtonItem.label
            } else {
                labelView.component = nil
            }
            setNeedsLayout()
        }
    }
    
    var radioButtonItem: RadioButtonItem? {
        return component as? RadioButtonItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        backgroundColor = ASAPP.styles.backgroundColor1
        
        addSubview(labelView)
        
        radioButtonView.layer.borderWidth = 1
        radioButtonView.layer.borderColor = ASAPP.styles.separatorColor2.cgColor
        radioButtonView.layer.cornerRadius = 5.0
        addSubview(radioButtonView)
    }
    
    // MARK: Layout
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        guard let radioButtonItem = radioButtonItem else {
            return (.zero, .zero)
        }
        let padding = radioButtonItem.style.padding
        
        // Max content size
        var maxContentSize = size
        if maxContentSize.width == 0 {
            maxContentSize.width = CGFloat.greatestFiniteMagnitude
        }
        if maxContentSize.height == 0 {
            maxContentSize.height = CGFloat.greatestFiniteMagnitude
        }
        maxContentSize.width -= padding.left + padding.right
        maxContentSize.height -= padding.top + padding.bottom
        
        // radioButton Size
        let radioButtonWidth = radioButtonItem.style.width > 0 ? radioButtonItem.style.width : RadioButtonItem.defaultWidth
        let radioButtonHeight = radioButtonItem.style.height > 0 ? radioButtonItem.style.height : RadioButtonItem.defaultHeight
        
        // Label Size
        let labelMargin = radioButtonItem.label.style.margin
        let maxLabelWidth = maxContentSize.width - radioButtonWidth - labelMargin.left - labelMargin.right
        let maxLabelHeight = maxContentSize.height - labelMargin.top - labelMargin.bottom
        if maxLabelWidth <= 0 || maxLabelHeight <= 0 {
            DebugLog.w(caller: self, "Unable to render radioButtonView because not enough space for label.")
            return (.zero, .zero)
        }
        let maxLabelSize = CGSize(width: maxLabelWidth, height: maxLabelHeight)
        var labelSize = labelView.sizeThatFits(maxLabelSize)
        labelSize.width = ceil(labelSize.width)
        labelSize.height = ceil(labelSize.height)
        
        let contentHeight = max(radioButtonHeight, labelSize.height)
        
        let radioButtonTop: CGFloat = padding.top + floor((contentHeight - radioButtonHeight) / 2.0)
        let radioButtonLeft = padding.left
        let radioButtonFrame = CGRect(x: radioButtonLeft, y: radioButtonTop, width: radioButtonWidth, height: radioButtonHeight)
        
        let labelLeft = radioButtonFrame.maxX + labelMargin.left
        let labelTop = padding.top + floor((contentHeight - labelSize.height) / 2.0)
        let labelFrame = CGRect(x: labelLeft, y: labelTop, width: labelSize.width, height: labelSize.height)
        
        return (radioButtonFrame, labelFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (radioButtonFrame, labelFrame) = getFramesThatFit(bounds.size)
        radioButtonView.frame = radioButtonFrame
        labelView.frame = labelFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let radioButtonItem = radioButtonItem else {
            return .zero
        }
        
        let (radioButtonFrame, labelFrame) = getFramesThatFit(size)
        if radioButtonFrame.isEmpty && labelFrame.isEmpty {
            return .zero
        }
        let padding = radioButtonItem.style.padding
        
        let labelStyle = radioButtonItem.label.style
        let labelMaxX = labelFrame.maxX + labelStyle.margin.right + padding.right
        let labelMaxY = labelFrame.maxY + labelStyle.margin.bottom + padding.bottom
        
        let radioButtonMaxY = radioButtonFrame.maxY + padding.bottom
        
        return CGSize(width: labelMaxX, height: max(radioButtonMaxY, labelMaxY))
    }
}
