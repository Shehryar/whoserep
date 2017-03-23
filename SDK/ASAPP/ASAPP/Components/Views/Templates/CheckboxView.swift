//
//  CheckboxView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class CheckboxView: UIView, ComponentView {

    let checkboxSquareView = UIView()
    
    let checkImageView = UIImageView()
    
    let labelView = LabelView()
    
    fileprivate var isChecked: Bool = false
    
    fileprivate var isTouching: Bool = false {
        didSet {
            if isTouching {
                backgroundColor = UIColor.black.withAlphaComponent(0.03)
            } else {
                backgroundColor = UIColor.clear
            }
        }
    }
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            if let checkboxItem = checkboxItem {
                labelView.component = checkboxItem.label
                isChecked = (checkboxItem.value as? Bool) ?? false
                resetState()
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
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = ASAPP.styles.separatorColor2.cgColor
        layer.cornerRadius = 5
        backgroundColor = ASAPP.styles.backgroundColor1
        
        addSubview(labelView)
        
        checkboxSquareView.layer.borderWidth = 1
        checkboxSquareView.layer.borderColor = ASAPP.styles.separatorColor2.cgColor
        checkboxSquareView.layer.cornerRadius = 5.0
        addSubview(checkboxSquareView)
        
        checkImageView.image = Images.asappImage(.iconCircleCheckmark)
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.alpha = 0.0
        addSubview(checkImageView)
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
        checkboxSquareView.frame = checkboxFrame
        labelView.frame = labelFrame
        
        checkImageView.frame = checkboxFrame
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
    
    fileprivate func resetState() {
        checkboxSquareView.layer.removeAllAnimations()
        checkboxSquareView.transform = .identity
        
        checkImageView.layer.removeAllAnimations()
        checkImageView.transform = .identity
        
        checkboxSquareView.alpha = isChecked ? 0 : 1
        checkImageView.alpha = isChecked ? 1 : 0
    }
    
    func toggleChecked(animated: Bool = false) {
        resetState()
        isChecked = !isChecked
        
        guard animated && isChecked else {
            resetState()
            return
        }
        
        checkImageView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.checkboxSquareView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self?.checkboxSquareView.alpha = 0.0
        }) { (completed) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseOut, animations: { [weak self] in
                self?.checkImageView.transform = .identity
                self?.checkImageView.alpha = 1.0
            }, completion: nil)
        }
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
            toggleChecked(animated: true)
            checkboxItem?.value = isChecked
        }
        isTouching = false
    }
}
