//
//  RadioButton.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButton: BaseComponentView {
    
    let centerView = UIView()
    
    var isSelected: Bool = false {
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
        
        addSubview(centerView)
        
        updateDisplay()
    }
    
    // MARK: Layout
    
    override func updateFrames() {
        guard let component = component else {
            return
        }
        
        var padding = component.style.padding
        if padding.left == 0 && padding.top == 0 && padding.right == 0 && padding.bottom == 0 {
            padding = RadioButtonItem.defaultPadding
        }
        let width = bounds.width - padding.left - padding.right
        let height = bounds.height - padding.top - padding.bottom
        
        centerView.frame = CGRect(x: padding.left, y: padding.top, width: width, height: height)
        
        layer.cornerRadius = bounds.height / 2.0
        centerView.layer.cornerRadius = centerView.bounds.height / 2.0
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
            width = RadioButtonItem.defaultWidth
            height = RadioButtonItem.defaultHeight
        }
        
        return CGSize(width: width, height: height)
    }
}

extension RadioButton {
    
    private func updateDisplay() {
        layer.borderWidth = max(1, layer.borderWidth)
   
        if isSelected {
            backgroundColor = ASAPP.styles.colors.controlTint
            layer.borderColor = ASAPP.styles.colors.controlTint.cgColor
        } else {
            backgroundColor = UIColor.clear
            layer.borderColor = ASAPP.styles.colors.separatorPrimary.cgColor
        }
        
        centerView.backgroundColor = ASAPP.styles.colors.backgroundPrimary
        centerView.isHidden = !isSelected
    }
}
