//
//  ButtonView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ButtonView: BaseComponentView {
    
    let defaultContentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    
    let button = UIButton()
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            if let buttonItem = buttonItem {
                var textStyle: TextStyle
                
                var textNormal: UIColor
                var textHighlighted: UIColor
                var textDisabled: UIColor
                
                var bgNormal: UIColor
                var bgHighlighted: UIColor
                var bgDisabled: UIColor
                
                var borderColor: UIColor?
                
                switch buttonItem.buttonStyle {
                case .primary:
                    textStyle = .blockButton
                    
                    textNormal = ASAPP.styles.primaryButtonTextColor
                    textHighlighted = textNormal
                    textDisabled = textNormal
                    
                    bgNormal = ASAPP.styles.primaryButtonBgColor
                    bgHighlighted = ASAPP.styles.primaryButtonBgColorHighlighted
                    bgDisabled = ASAPP.styles.primaryButtonBgColorDisabled
                    
                    borderColor = nil
                    break
                    
                case .secondary:
                    textStyle = .blockButton
                    
                    textNormal = ASAPP.styles.secondaryButtonTextColor
                    textHighlighted = textNormal
                    textDisabled = textNormal
                    
                    bgNormal = ASAPP.styles.secondaryButtonBgColor
                    bgHighlighted = ASAPP.styles.secondaryButtonBgColorHighlighted
                    bgDisabled = ASAPP.styles.secondaryButtonBgColorDisabled
                    
                    borderColor = ASAPP.styles.secondaryButtonBorderColor
                    break
                    
                case .text:
                    textStyle = .textButton
                    
                    textNormal = ASAPP.styles.textButtonColor
                    textHighlighted = ASAPP.styles.textButtonColorHighlighted
                    textDisabled = ASAPP.styles.textButtonColorDisabled
                    
                    bgNormal = UIColor.clear
                    bgHighlighted = UIColor.clear
                    bgDisabled = UIColor.clear
                    
                    borderColor = nil
                    break
                }
                
                button.setAttributedText(buttonItem.title, textStyle: textStyle,
                                         color: textNormal, state: .normal)
                
                button.setAttributedText(buttonItem.title, textStyle: textStyle,
                                         color: textHighlighted, state: .highlighted)
                
                button.setAttributedText(buttonItem.title, textStyle: textStyle,
                                         color: textDisabled, state: .disabled)
                
                button.setBackgroundImage(UIImage.imageWithColor(bgNormal), for: .normal)
                button.setBackgroundImage(UIImage.imageWithColor(bgHighlighted), for: .highlighted)
                button.setBackgroundImage(UIImage.imageWithColor(bgDisabled), for: .disabled)
                
                if let borderColor = borderColor {
                    button.layer.borderColor = borderColor.cgColor
                    button.layer.borderWidth = 1
                } else {
                    button.layer.borderColor = nil
                    button.layer.borderWidth = 0
                }
        
                var contentEdgeInsets = defaultContentEdgeInsets
                if buttonItem.style.padding != .zero {
                    contentEdgeInsets = buttonItem.style.padding
                }
                button.contentEdgeInsets = contentEdgeInsets
            } else {
                button.setTitle(nil, for: .normal)
            }
        }
    }
    
    var buttonItem: ButtonItem? {
        return component as? ButtonItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        button.clipsToBounds = true
        button.contentEdgeInsets = defaultContentEdgeInsets
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        addSubview(button)
        
        button.addTarget(self, action: #selector(ButtonView.onTap), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        button.frame = bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let buttonItem = buttonItem else {
            return .zero
        }
        
        var buttonSize = button.sizeThatFits(size)
        buttonSize.width = ceil(buttonSize.width)
        buttonSize.height = ceil(buttonSize.height)
        
        return buttonSize
    }
    
    // MARK: Action
    
    func onTap() {
        if let buttonItem = buttonItem {
            interactionHandler?.didTapButtonView(self, with: buttonItem)
        }
    }
}
