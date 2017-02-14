//
//  CancelConfirmControlsView.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/10/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

class CancelConfirmControlsView: UIView {

    var onCancelButtonTap: (() -> Void)?
    var onConfirmButtonTap: (() -> Void)?
    
    var cancelText: String = "CANCEL" {
        didSet {
            styleButton(cancelButton, withText: cancelText, font: cancelFont)
        }
    }
    
    var confirmText: String = "CONFIRM" {
        didSet {
            styleButton(confirmButton, withText: confirmText, font: confirmFont)
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
    
    fileprivate let cancelFont = Fonts.latoRegularFont(withSize: 12)
    fileprivate let confirmFont = Fonts.latoBoldFont(withSize: 12)
    
    fileprivate let buttonPaddingY: CGFloat = 17.0
    fileprivate let cancelButton = UIButton()
    fileprivate let confirmButton = UIButton()
    fileprivate let borderTop = UIView()
    fileprivate let borderMiddle = UIView()
    
    // MARK: Initialization
    
    func commonInit() {
        clipsToBounds = true
        
        styleButton(cancelButton, withText: cancelText, font: cancelFont)
        cancelButton.addTarget(self,
                               action: #selector(CancelConfirmControlsView.didTapCancelButton),
                               for: .touchUpInside)
        addSubview(cancelButton)
        
        styleButton(confirmButton, withText: confirmText, font: confirmFont)
        confirmButton.addTarget(self,
                               action: #selector(CancelConfirmControlsView.didTapConfirmButton),
                               for: .touchUpInside)
        addSubview(confirmButton)
        
        
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
    
    fileprivate func styleButton(_ button: UIButton,
                                 withText text: String,
                                 font: UIFont = Fonts.latoBoldFont(withSize: 12)) {
        
        button.clipsToBounds = true
        button.titleLabel?.font = font
        
        let attrTitle = NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName : UIColor(red:0.357, green:0.396, blue:0.494, alpha:1),
            NSFontAttributeName : font,
            NSKernAttributeName : 1.0
            ])
        
        let attrTitleDisabled = NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName : UIColor(red:0.357, green:0.396, blue:0.494, alpha:0.3),
            NSFontAttributeName : font,
            NSKernAttributeName : 1.0
            ])
        
        button.setAttributedTitle(attrTitle, for: .normal)
        button.setAttributedTitle(attrTitle, for: .highlighted)
        button.setAttributedTitle(attrTitleDisabled, for: .disabled)
        
        button.setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .normal)
        button.setBackgroundImage(UIImage.imageWithColor(UIColor(red: 0.905, green: 0.886, blue: 0.886, alpha: 1)), for: .highlighted)
        button.setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .disabled)
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
