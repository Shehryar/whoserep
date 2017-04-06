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
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                spinnerView.startAnimating()
            } else {
                spinnerView.stopAnimating()
            }
            button.isEnabled = !isLoading
        }
    }
    
    fileprivate let spinnerView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            isLoading = false
            
            if let buttonItem = buttonItem {
                var textStyle: TextStyle
                var buttonColors: ASAPPButtonColors
                
                switch buttonItem.buttonStyle {
                case .primary:
                    textStyle = .blockButton
                    buttonColors = ASAPP.styles.primaryButtonColors
                    break
                    
                case .secondary:
                    textStyle = .blockButton
                    buttonColors = ASAPP.styles.secondaryButtonColors
                    break
                    
                case .text:
                    textStyle = .textButton
                    buttonColors = ASAPP.styles.primaryTextButtonColors
                    break
                }
                
                button.setAttributedText(buttonItem.title, textStyle: textStyle,
                                         color: buttonColors.textNormal, state: .normal)
                
                button.setAttributedText(buttonItem.title, textStyle: textStyle,
                                         color: buttonColors.textHighlighted, state: .highlighted)
                
                button.setAttributedText(buttonItem.title, textStyle: textStyle,
                                         color: buttonColors.textDisabled, state: .disabled)
                
                button.setBackgroundImage(UIImage.imageWithColor(buttonColors.backgroundNormal), for: .normal)
                button.setBackgroundImage(UIImage.imageWithColor(buttonColors.backgroundHighlighted), for: .highlighted)
                button.setBackgroundImage(UIImage.imageWithColor(buttonColors.backgroundDisabled), for: .disabled)
                
                if let borderColor = buttonColors.border {
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
        
        spinnerView.hidesWhenStopped = true
        addSubview(spinnerView)
        
        button.addTarget(self, action: #selector(ButtonView.onTap), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func updateFrames() {
        button.frame = bounds
        
        spinnerView.sizeToFit()
        spinnerView.center = button.center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let _ = buttonItem else {
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
