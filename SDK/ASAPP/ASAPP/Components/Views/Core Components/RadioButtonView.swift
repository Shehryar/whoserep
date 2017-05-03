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
            updateDisplay()
        }
    }
    
    var onTap: ((_ currentItem: RadioButtonItem?) -> Void)?
    
    let checkboxView = UIView()
    
    let checkboxInnerView = UIView()
    
    let labelView = LabelView()
    
    fileprivate var isTouching: Bool = false {
        didSet {
            updateDisplay()
        }
    }
    
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
        
        backgroundColor = ASAPP.styles.colors.backgroundPrimary
        
        addSubview(labelView)
        
        checkboxView.layer.borderWidth = 1
        checkboxView.layer.borderColor = ASAPP.styles.colors.separatorPrimary.cgColor
        checkboxView.layer.cornerRadius = 5.0
        addSubview(checkboxView)
        
        checkboxInnerView.backgroundColor = UIColor.white
        checkboxInnerView.isHidden = true
        checkboxView.addSubview(checkboxInnerView)
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
        
        // Checkbox Size
        let checkboxWidth = radioButtonItem.style.width > 0 ? radioButtonItem.style.width : RadioButtonItem.defaultWidth
        let checkboxHeight = radioButtonItem.style.height > 0 ? radioButtonItem.style.height : RadioButtonItem.defaultHeight
        
        // Label Size
        let labelMargin = radioButtonItem.label.style.margin
        let maxLabelWidth = maxContentSize.width - checkboxWidth - labelMargin.left - labelMargin.right
        let maxLabelHeight = maxContentSize.height - labelMargin.top - labelMargin.bottom
        if maxLabelWidth <= 0 || maxLabelHeight <= 0 {
            DebugLog.w(caller: self, "Unable to render radioButtonView because not enough space for label.")
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
    
    override func updateFrames() {
        let (checkboxFrame, labelFrame) = getFramesThatFit(bounds.size)
        checkboxView.frame = checkboxFrame
        checkboxView.layer.cornerRadius = checkboxView.bounds.height / 2.0
        
        checkboxInnerView.frame = checkboxView.bounds.insetBy(dx: 5, dy: 5)
        checkboxInnerView.layer.cornerRadius = checkboxInnerView.bounds.height / 2.0
        
        labelView.frame = labelFrame
        labelView.updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let radioButtonItem = radioButtonItem else {
            return .zero
        }
        
        let (checkboxFrame, labelFrame) = getFramesThatFit(size)
        if checkboxFrame.isEmpty && labelFrame.isEmpty {
            return .zero
        }
        let padding = radioButtonItem.style.padding
        
        let labelStyle = radioButtonItem.label.style
        let labelMaxX = labelFrame.maxX + labelStyle.margin.right + padding.right
        let labelMaxY = labelFrame.maxY + labelStyle.margin.bottom + padding.bottom
        
        let checkboxMaxY = checkboxFrame.maxY + padding.bottom
        
        return CGSize(width: labelMaxX, height: max(checkboxMaxY, labelMaxY))
    }
}

extension RadioButtonView {
    
    fileprivate func updateDisplay() {
        if isSelected {
            checkboxView.layer.borderColor = ASAPP.styles.colors.controlTint.cgColor
            checkboxView.backgroundColor = ASAPP.styles.colors.controlTint
            checkboxInnerView.isHidden = false
        } else if isTouching {
            checkboxView.layer.borderColor = ASAPP.styles.colors.separatorSecondary.cgColor
            checkboxView.backgroundColor = ASAPP.styles.colors.separatorSecondary
            checkboxInnerView.isHidden = true
        } else {
            checkboxView.layer.borderColor = ASAPP.styles.colors.separatorSecondary.cgColor
            checkboxView.backgroundColor = UIColor.clear
            checkboxInnerView.isHidden = true
        }
    }
}

extension RadioButtonView {
    
    func touchesInBounds(_ touches: Set<UITouch>, with event: UIEvent?) -> Bool {
        if let touch = touches.first {
            let location = touch.location(in: self)
            return bounds.contains(location)
        }
        
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !touchesInBounds(touches, with: event) {
            isTouching = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouching && touchesInBounds(touches, with: event) {
            onTap?(radioButtonItem)
        }
        isTouching = false
    }
}
