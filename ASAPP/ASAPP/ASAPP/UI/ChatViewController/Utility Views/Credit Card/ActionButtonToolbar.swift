//
//  ActionButtonToolbar.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/10/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

class ActionButtonToolbar: UIToolbar {
    
    var onNextButtonTap: (() -> Void)? {
        didSet {
            updateButtons()
        }
    }
    
    var onPreviousButtonTap: (() -> Void)? {
        didSet {
            updateButtons()
        }
    }
    
    var onDoneButtonTap: (() -> Void)? {
        didSet {
            updateButtons()
        }
    }
    
    var onHideKeyboardTap: (() -> Void)? {
        didSet {
            updateButtons()
        }
    }
    
    var buttonTintColor: UIColor = UIColor(red:0.180, green:0.627, blue:0.867, alpha:1) {
        didSet {
            tintColor = buttonTintColor
            updateButtons()
        }
    }
    
    // MARK: Initialization
    
    func commonInit() {
        tintColor = buttonTintColor
        updateButtons()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK:- Display
    
    fileprivate func createImageButton(image: UIImage?, action: Selector?) -> UIBarButtonItem {
        let item = UIBarButtonItem(image: image, style: .plain, target: self, action: action)
        item.tintColor = buttonTintColor
        return item
    }
    
    func updateButtons() {
        var buttonItems = [UIBarButtonItem]()
        
        // Hide Keyboard
        if onHideKeyboardTap != nil {
            buttonItems.append(createImageButton(image: Images.asappImage(.iconHideKeyboard), action: #selector(ActionButtonToolbar.didTapHideKeyboard)))
        }
        
        // Flexible Space
        let flexItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        buttonItems.append(flexItem)
        
        
        // Previous / Next
        if onPreviousButtonTap != nil {
            buttonItems.append(createImageButton(image: Images.asappImage(.iconArrowLeft), action: #selector(ActionButtonToolbar.didTapPreviousButton)))
        }
        if onNextButtonTap != nil {
            buttonItems.append(createImageButton(image: Images.asappImage(.iconArrowRight), action: #selector(ActionButtonToolbar.didTapNextButton)))
        }
        
        // Done
        if onDoneButtonTap != nil {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ActionButtonToolbar.didTapDoneButton))
            doneButton.tintColor = buttonTintColor
            doneButton.setTitleTextAttributes([
                NSForegroundColorAttributeName : buttonTintColor
                ], for: .normal)
            doneButton.setTitleTextAttributes([
                NSForegroundColorAttributeName : buttonTintColor.withAlphaComponent(0.5)
                ], for: .highlighted)
            buttonItems.append(doneButton)
        }
        
        items = buttonItems

        sizeToFit()
    }

    // MARK:- Actions
    
    func didTapHideKeyboard() {
        onHideKeyboardTap?()
    }
    
    func didTapDoneButton() {
        onDoneButtonTap?()
    }
    
    func didTapPreviousButton() {
        onPreviousButtonTap?()
    }
    
    func didTapNextButton() {
        onNextButtonTap?()
    }
}
