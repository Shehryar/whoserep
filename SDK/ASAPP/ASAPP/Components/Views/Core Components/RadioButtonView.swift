//
//  RadioButton.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonView: _RootComponentWrapperView {
    
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
    
    var isChecked: Bool {
        return component?.isChecked ?? false
    }
    
    // Init
    
    override func commonInit() {
        super.commonInit()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RadioButtonView.didTap)))
    }
    
    // Actions
    
    func didTap() {
        component?.isChecked = !isChecked
        
        updateRadioButton()
        
        contentHandler?.componentView(self, didUpdateContent: isChecked, requiresLayoutUpdate: false)
    }
    
    func updateRadioButton() {
        let isChecked = self.isChecked
        enumerateNestedComponentViews() { (childView) -> Bool in
            if let checkbox = childView as? Checkbox {
                checkbox.isChecked = isChecked
                return true
            }
            return false
        }
    }
}
