//
//  CheckboxView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class CheckboxView: BaseComponentView {

    let checkboxSquareView = UIView()
    
    let checkImageView = UIImageView()
    
    let labelView = LabelView()
    
    let highlightView = UIView()
    
    fileprivate var isChecked: Bool = false
    
    fileprivate var isTouching: Bool = false {
        didSet {
            highlightView.isHidden = !isTouching
        }
    }
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            if let checkboxItem = checkboxItem {
                labelView.component = checkboxItem.label
                isChecked = (checkboxItem.value as? Bool) ?? false
            } else {
                labelView.component = nil
            }
            updateDisplay()
        }
    }
    
    var checkboxItem: CheckboxItem? {
        return component as? CheckboxItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
    
        backgroundColor = ASAPP.styles.backgroundColor1
        
        addSubview(labelView)
        
        checkboxSquareView.layer.borderWidth = 1
        checkboxSquareView.layer.borderColor = ASAPP.styles.separatorColor2.cgColor
        checkboxSquareView.layer.cornerRadius = 5.0
        addSubview(checkboxSquareView)
        
        checkImageView.image = Images.asappImage(.iconCheckmark)?.tinted(UIColor.white)
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.isHidden = true
        addSubview(checkImageView)
        
        highlightView.isUserInteractionEnabled = false
        highlightView.backgroundColor = UIColor.blue.withAlphaComponent(0.05)
        highlightView.isHidden = true
        addSubview(highlightView)
        
        updateDisplay()
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
        checkboxSquareView.frame = checkboxFrame
        labelView.frame = labelFrame
        
        checkImageView.frame = checkboxFrame.insetBy(dx: 3, dy: 3)
        highlightView.frame = bounds
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

extension CheckboxView {
    
    fileprivate func updateDisplay() {
        if isChecked {
            checkboxSquareView.backgroundColor = ASAPP.styles.controlTintColor
            checkboxSquareView.layer.borderColor = ASAPP.styles.controlTintColor.cgColor
        } else {
            checkboxSquareView.backgroundColor = UIColor.clear
            checkboxSquareView.layer.borderColor = ASAPP.styles.separatorColor2.cgColor
        }
        
        checkImageView.isHidden = !isChecked
    }
    
    func toggleChecked() {
        isChecked = !isChecked
        updateDisplay()
    }
}

extension CheckboxView {
    
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
            toggleChecked()
            checkboxItem?.value = isChecked
        }
        isTouching = false
    }
}
