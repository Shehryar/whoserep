//
//  Checkbox.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class Checkbox: BaseComponentView {
    
    let checkImageView = UIImageView()
    
    var isChecked: Bool = false {
        didSet {
            updateDisplay()
        }
    }

    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            updateDisplay()
            setNeedsLayout()
        }
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        backgroundColor = ASAPP.styles.colors.backgroundPrimary
        
        layer.borderWidth = 1
        layer.borderColor = ASAPP.styles.colors.separatorSecondary.cgColor
        layer.cornerRadius = 5.0
        
        checkImageView.image = Images.getImage(.iconCheckmark)?.tinted(UIColor.white)
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.isHidden = true
        addSubview(checkImageView)
        
        updateDisplay()
    }
    
    // MARK: Layout
    
    override func updateFrames() {
        guard let component = component else {
            return
        }
        
        var padding = component.style.padding
        if padding.left == 0 && padding.top == 0 && padding.right == 0 && padding.bottom == 0 {
            padding = CheckboxItem.defaultPadding
        }
        let width = bounds.width - padding.left - padding.right
        let height = bounds.height - padding.top - padding.bottom
        
        checkImageView.frame = CGRect(x: padding.left, y: padding.top, width: width, height: height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let component = component else {
            return .zero
        }
        
        let width: CGFloat
        let height: CGFloat
        if component.style.width > 0 && component.style.height > 0 {
            width = component.style.width
            height = component.style.height
        } else {
            width = CheckboxItem.defaultWidth
            height = CheckboxItem.defaultHeight
        }
        
        return CGSize(width: width, height: height)
    }
}

extension Checkbox {
    
    private func updateDisplay() {
        layer.borderWidth = max(1, layer.borderWidth)
        if layer.cornerRadius == 0 {
            layer.cornerRadius = 4
        }
        
        if isChecked {
            backgroundColor = ASAPP.styles.colors.controlTint
            layer.borderColor = ASAPP.styles.colors.controlTint.cgColor
        } else {
            backgroundColor = UIColor.clear
            layer.borderColor = ASAPP.styles.colors.separatorPrimary.cgColor
        }
        
        checkImageView.isHidden = !isChecked
    }
}
