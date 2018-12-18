//
//  RadioButton.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonView: RootComponentWrapperView {
    
    // MARK: Properties
    
    override var component: Component? {
        didSet {
            if let radioButtonViewItem = component as? RadioButtonViewItem {
                rootView = radioButtonViewItem.root.createView()?.view
                updateRadioButton()
            } else {
                rootView = nil
            }
        }
    }
    
    var isSelected: Bool = false {
        didSet {            
            updateRadioButton()
        }
    }
    
    var onTap: (() -> Void)?
    
    // Init
    
    override func commonInit() {
        super.commonInit()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RadioButtonView.didTap)))
    }
    
    // Actions
    
    @objc func didTap() {
        onTap?()
    }
    
    func updateRadioButton() {
        let isSelected = self.isSelected
        var label = ""
        enumerateNestedComponentViews { childView  in
            if let radioButton = childView as? RadioButton {
                radioButton.isSelected = isSelected
            }
            if let labelView = childView as? LabelView {
                label = labelView.labelItem?.text ?? ""
            }
        }
        
        backgroundColor = ASAPP.styles.colors.controlBackground
        layer.borderWidth = component?.style.borderWidth ?? 0
        layer.borderColor = (component?.style.borderColor ?? UIColor.clear).cgColor
        layer.cornerRadius = component?.style.cornerRadius ?? 3
        
        isAccessibilityElement = true
        accessibilityLabel = label
        accessibilityTraits = isSelected ? .selected : .button
    }
}
