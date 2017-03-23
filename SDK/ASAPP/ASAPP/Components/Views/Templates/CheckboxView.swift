//
//  CheckboxView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class CheckboxView: UIView, ComponentView {

    let checkboxBoxView = UIView()
    
    let labelView = LabelView()
    
    var isChecked: Bool = false
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            if let checkboxItem = checkboxItem {
                labelView.component = checkboxItem.label
            } else {
                labelView.component = nil
            }
        }
    }
    
    var checkboxItem: CheckboxItem? {
        return component as? CheckboxItem
    }
    
    weak var interactionHandler: InteractionHandler?
    
    // MARK: Init
    
    func commonInit() {
        
        layer.borderWidth = 1
        layer.borderColor = ASAPP.styles.separatorColor2.cgColor
        layer.cornerRadius = 5
        backgroundColor = ASAPP.styles.backgroundColor1
        
        addSubview(labelView)
        
        checkboxBoxView.layer.borderWidth = 1
        checkboxBoxView.layer.borderColor = ASAPP.styles.separatorColor2.cgColor
        checkboxBoxView.layer.cornerRadius = 5.0
        addSubview(checkboxBoxView)
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
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        guard let checkboxItem = checkboxItem else {
            return (.zero, .zero)
        }
        let padding = checkboxItem.style.padding
        
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
        
        // Checkbox Size
        let checkboxWidth = checkboxItem.style.width > 0 ? checkboxItem.style.width : CheckboxItem.defaultWidth
        let checkboxHeight = checkboxItem.style.height > 0 ? checkboxItem.style.height : CheckboxItem.defaultHeight
        
        // Label Size
        let labelMargin = checkboxItem.label.style.margin
        let maxLabelWidth = maxContentSize.width - checkboxWidth - labelMargin.left - labelMargin.right
        let maxLabelHeight = maxContentSize.height - labelMargin.top - labelMargin.bottom
        if maxLabelWidth <= 0 || maxLabelHeight <= 0 {
            DebugLog.w(caller: self, "Unable to render CheckboxView because not enough space for label.")
            return (.zero, .zero)
        }
        let maxLabelSize = CGSize(width: maxLabelWidth, height: maxLabelHeight)
        var labelSize = labelView.sizeThatFits(maxLabelSize)
        labelSize.width = ceil(labelSize.width)
        labelSize.height = ceil(labelSize.height)
        
        let contentHeight = max(checkboxHeight, labelSize.height)
        
        let checkboxTop: CGFloat = padding.top + floor((contentHeight - checkboxHeight) / 2.0)
        let checkboxLeft = padding.left
        let checkboxFrame = CGRect(x: checkboxLeft, y: checkboxTop, width: checkboxWidth, height: checkboxHeight)
        
        let labelLeft = checkboxFrame.maxX + labelMargin.left
        let labelTop = padding.top + floor((contentHeight - labelSize.height) / 2.0)
        let labelFrame = CGRect(x: labelLeft, y: labelTop, width: labelSize.width, height: labelSize.height)
        
        return (checkboxFrame, labelFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (checkboxFrame, labelFrame) = getFramesThatFit(bounds.size)
        checkboxBoxView.frame = checkboxFrame
        labelView.frame = labelFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let checkboxItem = checkboxItem else {
            return .zero
        }
        
        let (checkboxFrame, labelFrame) = getFramesThatFit(size)
        if checkboxFrame.isEmpty && labelFrame.isEmpty {
            return .zero
        }
        let padding = checkboxItem.style.padding
        
        let labelStyle = checkboxItem.label.style
        let labelMaxX = labelFrame.maxX + labelStyle.margin.right + labelStyle.padding.right + padding.right
        let labelMaxY = labelFrame.maxY + labelStyle.margin.bottom + labelStyle.padding.bottom + padding.bottom
        
        let checkboxMaxY = checkboxFrame.maxY + padding.bottom
        
        return CGSize(width: labelMaxX, height: max(checkboxMaxY, labelMaxY))
    }
}
