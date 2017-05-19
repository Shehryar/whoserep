//
//  CheckboxView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class CheckboxView: _RootComponentWrapperView {

    // MARK: Properties
    
    override var component: Component? {
        didSet {
            if let checkboxViewItem = component as? CheckboxViewItem {
                rootView = checkboxViewItem.root.createView()?.view
                updateCheckbox()
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
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CheckboxView.didTap)))
    }
    
    // Actions
    
    func didTap() {
        component?.isChecked = !isChecked
        
        updateCheckbox()
        
        contentHandler?.componentView(self, didUpdateContent: isChecked, requiresLayoutUpdate: false)
    }
    
    func updateCheckbox() {
        let isChecked = self.isChecked
        enumerateNestedComponentViews() { (childView) -> Void in
            if let checkbox = childView as? Checkbox {
                checkbox.isChecked = isChecked
            }
        }
        
        if isChecked {
            backgroundColor = ASAPP.styles.colors.controlSelectedBackground
        } else if let background = component?.style.backgroundColor {
            backgroundColor = background
        } else {
            backgroundColor = ASAPP.styles.colors.backgroundPrimary
        }
    }
}
