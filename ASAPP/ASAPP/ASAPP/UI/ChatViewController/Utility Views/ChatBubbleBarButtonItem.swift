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

// MARK:- ChatBubbleBarButtonItem

extension UIBarButtonItem {
    
    class func chatBubbleBarButtonItem(title: String,
                                       font: UIFont,
                                       textColor: UIColor,
                                       backgroundColor: UIColor,
                                       style: ChatBubbleBarButtonItemStyle,
                                       target: Any?,
                                       action: Selector) -> UIBarButtonItem {
        
        let button = UIButton()
        
        // Styling
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
        button.setBackgroundImage(getChatBubbleBackgroundImage(forStyle: style, color: backgroundColor, alpha: 1), for: .normal)
        button.setBackgroundImage( getChatBubbleBackgroundImage(forStyle: style, color: backgroundColor, alpha: 0.6), for: .highlighted)
        
        // Sizing
        let insets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 11)
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
    
    // Helpers
    
    private class func getChatBubbleBackgroundImage(forStyle style: ChatBubbleBarButtonItemStyle, color: UIColor, alpha: CGFloat) -> UIImage? {
        var image: UIImage?
        switch style {
        case .ask:
            image = Images.buttonAskBG()?.tinted(color, alpha: alpha)
            break
            
        case .respond:
            image = Images.buttonRespondBG()?.tinted(color, alpha: alpha)
            break
        }
        
        return image?.resizableImage(withCapInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                                     resizingMode: .stretch)
    }
}

// MARK:- CircleCloseBarButtonItem

extension UIBarButtonItem {
    
    class func circleCloseBarButtonItem(foregroundColor: UIColor,
                                        backgroundColor: UIColor,
                                        target: Any?,
                                        action: Selector) -> UIBarButtonItem {
        let button = UIButton()
        
        // Styling
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(Images.iconX()?.tinted(foregroundColor, alpha: 1), for: .normal)
        button.setImage(Images.iconX()?.tinted(foregroundColor, alpha: 0.6), for: .highlighted)
        button.setBackgroundImage(Images.buttonCloseBG()?.tinted(backgroundColor, alpha: 1), for: .normal)
        button.setBackgroundImage(Images.buttonCloseBG()?.tinted(backgroundColor, alpha: 0.6), for: .highlighted)
        
        // Sizing
        let imageSize: CGFloat = 8
        let imagePadding: CGFloat = 9
        
        button.imageEdgeInsets = UIEdgeInsets(top: imagePadding, left: imagePadding, bottom: imagePadding, right: imagePadding)
        let buttonSize = imagePadding + imageSize + imagePadding
        button.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Target-Action
        button.addTarget(target, action: action, for: .touchUpInside)
        
        return UIBarButtonItem(customView: button)
    }
}
