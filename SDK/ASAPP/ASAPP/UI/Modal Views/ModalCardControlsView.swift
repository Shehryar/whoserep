//
//  ModalCardControlsView.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/10/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

class ModalCardControlsView: UIView {

    var onCancelButtonTap: (() -> Void)?
    var onConfirmButtonTap: (() -> Void)?
    
    var cancelText: String = ASAPP.strings.modalViewCancelButton {
        didSet {
            updateCancelButton()
        }
    }
    
    var confirmText: String = ASAPP.strings.modalViewSubmitButton {
        didSet {
            updateConfirmButton()
        }
    }
    
    var cancelButtonHidden = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    var cancelButtonEnabled = true {
        didSet {
            cancelButton.isEnabled = cancelButtonEnabled
        }
    }
    
    var confirmButtonEnabled = true {
        didSet {
            confirmButton.isEnabled = confirmButtonEnabled
        }
    }
    
    let buttonColor =  UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 1)
    let buttonColorDisabled = UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 0.3)
    
    var borderColor: UIColor = UIColor(red: 0.925, green: 0.906, blue: 0.906, alpha: 1) {
        didSet {
            borderTop.backgroundColor = borderColor
            borderMiddle.backgroundColor = borderColor
        }
    }
    
    var borderWidth: CGFloat = 1.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    fileprivate let buttonPaddingY: CGFloat = 17.0
    fileprivate let cancelButton = UIButton()
    fileprivate let confirmButton = UIButton()
    fileprivate let borderTop = UIView()
    fileprivate let borderMiddle = UIView()
    
    // MARK: Initialization
    
    func commonInit() {
        clipsToBounds = true
        
        let buttonBg = UIImage.imageWithColor(UIColor.white)
        let buttonBgHighlighted = UIImage.imageWithColor(UIColor(red: 0.905, green: 0.886, blue: 0.886, alpha: 1))
        
        cancelButton.clipsToBounds = true
        cancelButton.setBackgroundImage(buttonBg, for: .normal)
        cancelButton.setBackgroundImage(buttonBgHighlighted, for: .highlighted)
        cancelButton.setBackgroundImage(buttonBg, for: .disabled)
        cancelButton.addTarget(self,
                               action: #selector(ModalCardControlsView.didTapCancelButton),
                               for: .touchUpInside)
        addSubview(cancelButton)
        
        confirmButton.clipsToBounds = true
        confirmButton.setBackgroundImage(buttonBg, for: .normal)
        confirmButton.setBackgroundImage(buttonBgHighlighted, for: .highlighted)
        confirmButton.setBackgroundImage(buttonBg, for: .disabled)
        confirmButton.addTarget(self,
                               action: #selector(ModalCardControlsView.didTapConfirmButton),
                               for: .touchUpInside)
        addSubview(confirmButton)
        
        updateCancelButton()
        updateConfirmButton()
        
        borderMiddle.backgroundColor = borderColor
        addSubview(borderMiddle)
        
        borderTop.backgroundColor = borderColor
        addSubview(borderTop)
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
    
    func updateCancelButton() {
        cancelButton.updateText(cancelText,
                                textStyle: ASAPP.styles.textStyles.button,
                                colors: ASAPP.styles.colors.buttonSecondary)
    }
    
    func updateConfirmButton() {
        confirmButton.updateText(confirmText,
                                 textStyle: ASAPP.styles.textStyles.button,
                                 colors: ASAPP.styles.colors.buttonPrimary)
    }
    
    // MARK:- Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let buttonHeight = ceil(confirmButton.sizeThatFits(CGSize(width: size.width, height: 0)).height)
        
        return CGSize(width: size.width, height: buttonHeight + 2 * buttonPaddingY)
    }
    
    func updateFrames() {
        borderTop.frame = CGRect(x: 0, y: 0, width: bounds.width, height: borderWidth)
        
        var cancelButtonWidth = floor(bounds.midX)
        if cancelButtonHidden {
            cancelButtonWidth = 0.0
        }
        let confirmButtonWidth = bounds.width - cancelButtonWidth
        
        cancelButton.frame = CGRect(x: 0, y: 0, width: cancelButtonWidth, height: bounds.height)
        confirmButton.frame = CGRect(x: cancelButton.frame.maxX, y: 0, width: confirmButtonWidth, height: bounds.height)
        
        let borderMiddleLeft = confirmButton.frame.minX - borderWidth
        borderMiddle.frame = CGRect(x: borderMiddleLeft, y: 0, width: borderWidth, height: bounds.height)
        
    }
    
    // MARK:- Actions
    
    func didTapCancelButton() {
        onCancelButtonTap?()
    }
    
    func didTapConfirmButton() {
        onConfirmButtonTap?()
    }
}
