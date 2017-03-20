//
//  ButtonView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ButtonView: UIView, ComponentView {
    
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
                
                switch buttonItem.style {
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
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
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
    
    func getFrameThatFits(_ size: CGSize) -> CGRect {
        guard let buttonItem = buttonItem else {
            return .zero
        }
        let padding = buttonItem.layout.padding
        let maxWidth = size.width - padding.left - padding.right
        let height = ceil(button.sizeThatFits(CGSize(width: maxWidth, height: 0)).height)
        let top = height > 0 ? padding.top : 0
        return CGRect(x: padding.left, y: top, width: maxWidth, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame = getFrameThatFits(bounds.size)
        button.frame = frame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let buttonItem = buttonItem else {
            return .zero
        }
        
        let frame = getFrameThatFits(size)
        let height = frame.height > 0 ? frame.height + buttonItem.layout.padding.bottom : 0
        
        return CGSize(width: size.width, height: height)
    }
}
