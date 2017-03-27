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

enum NavBarButtonSide {
    case left
    case right
}

// MARK:- ChatBubbleBarButtonItem

extension UIBarButtonItem {
    
    /// Returns (textColor, backgroundColor, font)
    private class func getButtonColorsFontInset(location: NavBarButtonLocation,
                                                side: NavBarButtonSide) -> (UIColor, UIColor?, UIFont, UIEdgeInsets) {
        let textColor: UIColor
        let backgroundColor: UIColor?
        let font: UIFont
        let insets: UIEdgeInsets
        switch ASAPP.styles.navBarButtonStyle {
        case .bubble:
            switch location {
            case .chat:
                textColor = ASAPP.styles.navBarButtonForegroundColor
                backgroundColor = ASAPP.styles.navBarButtonBackgroundColor

                break
                
            case .predictive:
                textColor = ASAPP.styles.predictiveNavBarButtonForegroundColor
                backgroundColor = ASAPP.styles.predictiveNavBarButtonBackgroundColor
                break
            }
            font = ASAPP.styles.font(for: .navBarButtonBubble)
            insets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 11)
            break
            
        case .text:
            switch location {
            case .chat:
                textColor = ASAPP.styles.navBarButtonColor
                break
                
            case .predictive:
                textColor = ASAPP.styles.predictiveNavBarButtonColor
                break
            }
            backgroundColor = nil
            font = ASAPP.styles.font(for: .navBarButtonText)
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
    
    class func asappCloseBarButtonItem(location: NavBarButtonLocation,
                                       side: NavBarButtonSide,
                                       target: Any?,
                                       action: Selector) -> UIBarButtonItem {
        
        let foregroundColor: UIColor
        let backgroundColor: UIColor?
        let imageSize: CGFloat
        let imageInsets: UIEdgeInsets
        switch ASAPP.styles.navBarButtonStyle {
        case .bubble:
            switch location {
            case .chat:
                foregroundColor = ASAPP.styles.navBarButtonForegroundColor
                backgroundColor = ASAPP.styles.navBarButtonBackgroundColor
                break
                
            case .predictive:
                foregroundColor = ASAPP.styles.predictiveNavBarButtonForegroundColor
                backgroundColor = ASAPP.styles.predictiveNavBarButtonBackgroundColor
                break
            }
            imageSize = 8
            imageInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
            break
            
        case .text:
            foregroundColor = ASAPP.styles.navBarButtonColor
            backgroundColor = nil
            imageSize = 34
            switch side {
            case .left:
                imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 6)
                break
                
            case .right:
                imageInsets = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 0)
                break
            }
            break
        }
        
        
        
        let button = UIButton()
        
        // X-Image
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(Images.asappImage(.iconX)?.tinted(foregroundColor, alpha: 1), for: .normal)
        button.setImage(Images.asappImage(.iconX)?.tinted(foregroundColor, alpha: 0.6), for: .highlighted)
        
        // Bubble
        if let backgroundColor = backgroundColor {
            button.setBackgroundImage(Images.asappImage(.buttonCloseBG)?.tinted(backgroundColor, alpha: 1), for: .normal)
            button.setBackgroundImage(Images.asappImage(.buttonCloseBG)?.tinted(backgroundColor, alpha: 0.6), for: .highlighted)
        }
        
        // Sizing
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
