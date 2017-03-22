//
//  ButtonView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ButtonView: UIView, ComponentView {
    
    let defaultContentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
    
    let button = UIButton()
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            if let buttonItem = buttonItem {
                var textStyle: TextStyle
                
                var textNormal: UIColor
                var textHighlighted: UIColor
                var textDisabled: UIColor
                
                var bgNormal: UIColor
                var bgHighlighted: UIColor
                var bgDisabled: UIColor
                
                switch buttonItem.buttonStyle {
                case .block:
                    textStyle = .blockButton
                    
                    textNormal = ASAPP.styles.blockButtonTextColor
                    textHighlighted = textNormal
                    textDisabled = textNormal
                    
                    bgNormal = ASAPP.styles.blockButtonBgColor
                    bgHighlighted = ASAPP.styles.blockButtonBgColorHighlighted
                    bgDisabled = ASAPP.styles.blockButtonBgColorDisabled
                    break
                    
                case .text:
                    textStyle = .textButton
                    
                    textNormal = ASAPP.styles.textButtonColor
                    textHighlighted = ASAPP.styles.textButtonColorHighlighted
                    textDisabled = ASAPP.styles.textButtonColorDisabled
                    
                    bgNormal = UIColor.clear
                    bgHighlighted = UIColor.clear
                    bgDisabled = UIColor.clear
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
    
    func commonInit() {
        button.clipsToBounds = true
        button.contentEdgeInsets = defaultContentEdgeInsets
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        addSubview(button)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
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
}
