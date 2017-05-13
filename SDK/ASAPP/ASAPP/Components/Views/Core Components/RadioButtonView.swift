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
    
    func didTap() {
        onTap?()
    }
    
    func updateRadioButton() {
        let isSelected = self.isSelected
        enumerateNestedComponentViews() { (childView) -> Void in
            if let radioButton = childView as? RadioButton {
                radioButton.isSelected = isSelected
            }
        }
    }
}
