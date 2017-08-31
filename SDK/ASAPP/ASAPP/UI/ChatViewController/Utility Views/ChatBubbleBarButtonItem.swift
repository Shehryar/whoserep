//
//  ChatBubbleBarButtonItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum ChatBubbleBarButtonItemStyle {
    case ask
    case respond
}

enum NavBarButtonLocation {
    case chat
    case predictive
}

// MARK:- ChatBubbleBarButtonItem

extension UIBarButtonItem {
    
    /// Returns (textColor, backgroundColor, font)
    private class func getButtonColorsFontInset(location: NavBarButtonLocation, side: NavBarButtonSide) -> (UIColor, UIColor?, UIFont, UIEdgeInsets) {
        let textColor: UIColor
        let backgroundColor: UIColor?
        let font: UIFont
        let insets: UIEdgeInsets
        switch ASAPP.styles.navBarButtonStyle {
        case .bubble:
            switch location {
            case .chat:
                textColor = ASAPP.styles.colors.navBarButtonForeground
                backgroundColor = ASAPP.styles.colors.navBarButtonBackground

                break
                
            case .predictive:
                textColor = ASAPP.styles.colors.predictiveNavBarButtonForeground
                backgroundColor = ASAPP.styles.colors.predictiveNavBarButtonBackground
                break
            }
            font = ASAPP.styles.textStyles.link.font
            insets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 11)
            break
            
        case .text:
            switch location {
            case .chat:
                textColor = ASAPP.styles.colors.navBarButton
                break
                
            case .predictive:
                textColor = ASAPP.styles.colors.predictiveNavBarButton
                break
            }
            backgroundColor = nil
            font = ASAPP.styles.textStyles.button.font
            switch side {
            case .left:
                insets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 11)
                break
                
            case .right:
                insets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 0)
                break
            }
            
            break
        }

        return (textColor, backgroundColor, font, insets)
    }
    
    
    class func asappBarButtonItem(title: String,
                                  style: ChatBubbleBarButtonItemStyle,
                                  location: NavBarButtonLocation,
                                  side: NavBarButtonSide,
                                  target: Any?,
                                  action: Selector) -> UIBarButtonItem {
        
        let (textColor, backgroundColor, font, insets) = getButtonColorsFontInset(location: location, side: side)
        
        let button = UIButton()
        
        // Text
        
        button.setAttributedTitle(NSAttributedString(string: title, attributes: [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : textColor,
            NSKernAttributeName : 1
            ]), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: title, attributes: [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : textColor.withAlphaComponent(0.6),
            NSKernAttributeName : 1
            ]), for: .highlighted)
        
        // Bubble
        
        if let backgroundColor = backgroundColor {
            button.setBackgroundImage(getChatBubbleBackgroundImage(forStyle: style,
                                                                   color: backgroundColor,
                                                                   alpha: 1), for: .normal)
            button.setBackgroundImage( getChatBubbleBackgroundImage(forStyle: style,
                                                                    color: backgroundColor,
                                                                    alpha: 0.6), for: .highlighted)
        }
        
        // Sizing
        if let titleLabel = button.titleLabel {
            let titleSize = titleLabel.sizeThatFits(.zero)
            let buttonHeight = ceil(titleSize.height) + insets.top + insets.bottom
            let buttonWidth = ceil(titleSize.width) + insets.left + insets.right
            button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        } else {
            button.titleEdgeInsets = insets
            button.sizeToFit()
        }
        
        // Target-Action
        button.addTarget(target, action: action, for: .touchUpInside)
        
        return UIBarButtonItem(customView: button)
    }
    
    class func asappCloseBarButtonItem(location: NavBarButtonLocation, side: NavBarButtonSide = .right, segue: ASAPPSegue = .present, target: Any?, action: Selector) -> UIBarButtonItem {
        var foregroundColor: UIColor
        var backgroundColor: UIColor?
        var image: UIImage?
        var imageSize: CGFloat
        var imageInsets: UIEdgeInsets
        
        switch ASAPP.styles.navBarButtonStyle {
        case .bubble:
            switch location {
            case .chat:
                foregroundColor = ASAPP.styles.colors.navBarButtonForeground
                backgroundColor = ASAPP.styles.colors.navBarButtonBackground
            case .predictive:
                foregroundColor = ASAPP.styles.colors.predictiveNavBarButtonForeground
                backgroundColor = ASAPP.styles.colors.predictiveNavBarButtonBackground
            }
            
            imageSize = 8
            imageInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)

        case .text:
            foregroundColor = ASAPP.styles.colors.navBarButton
            backgroundColor = nil
            imageSize = 13
            switch side {
            case .left:
                imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 6)
            case .right:
                imageInsets = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 0)
            }
        }
        
        let button = SizedImageOnlyButton()
        button.imageView?.contentMode = .scaleAspectFit
        
        switch segue {
        case .present:
            image = Images.asappImage(.iconX)
        case .push:
            foregroundColor = ASAPP.styles.colors.navBarButtonBackground
            backgroundColor = nil
            image = Images.asappImage(.iconArrowLeft)
            imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 6)
            imageSize = 24
        }
        
        button.setImage(image?.tinted(foregroundColor, alpha: 1), for: .normal)
        button.setImage(image?.tinted(foregroundColor, alpha: 0.6), for: .highlighted)
        button.imageSize = CGSize(width: imageSize, height: imageSize)
        
        // Bubble
        if let backgroundColor = backgroundColor {
            button.setBackgroundImage(Images.asappImage(.buttonCloseBG)?.tinted(backgroundColor, alpha: 1), for: .normal)
            button.setBackgroundImage(Images.asappImage(.buttonCloseBG)?.tinted(backgroundColor, alpha: 0.6), for: .highlighted)
        }
        
        // Sizing
        button.contentEdgeInsets = .zero
        button.imageEdgeInsets = imageInsets
        let buttonSize = CGSize(width: imageSize + imageInsets.left + imageInsets.right,
                                height: imageSize + imageInsets.top + imageInsets.bottom)
        
        button.frame = CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height)
        
        // Target-Action
        button.addTarget(target, action: action, for: .touchUpInside)
        
        return UIBarButtonItem(customView: button)
    
    }
    
    // MARK:- Bubble Image Helper
    
    private class func getChatBubbleBackgroundImage(forStyle style: ChatBubbleBarButtonItemStyle, color: UIColor, alpha: CGFloat) -> UIImage? {
        var image: UIImage?
        switch style {
        case .ask:
            image = Images.asappImage(.buttonAskBG)?.tinted(color, alpha: alpha)
            break
            
        case .respond:
            image = Images.asappImage(.buttonRespondBG)?.tinted(color, alpha: alpha)
            break
        }
        
        return image?.resizableImage(withCapInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                                     resizingMode: .stretch)
    }
}

class SizedImageOnlyButton: UIButton {

    var imageSize: CGSize?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageSize = imageSize {
            let top = contentEdgeInsets.top + imageEdgeInsets.top
            let left = contentEdgeInsets.left + imageEdgeInsets.left
            imageView?.frame = CGRect(x: left, y: top, width: imageSize.width, height: imageSize.height)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let imageSize = imageSize else {
            return super.sizeThatFits(size)
        }
        
        let width = imageSize.width + imageEdgeInsets.left + imageEdgeInsets.right + contentEdgeInsets.left + contentEdgeInsets.right
        let height = imageSize.height + imageEdgeInsets.top + imageEdgeInsets.bottom + contentEdgeInsets.top + contentEdgeInsets.bottom
        return CGSize(width: width, height: height)
    }
    
}
