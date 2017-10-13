//
//  NavBarButtonItem.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 10/11/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum NavBarButtonStyle {
    case ask
    case respond
}

enum NavBarButtonLocation {
    case chat
    case predictive
}

class NavBarButtonItem: UIBarButtonItem {
    
    private let styles: Styles
    private let side: NavBarButtonSide
    private let location: NavBarButtonLocation
    
    private struct Styles {
        let textColor: UIColor
        let backgroundColor: UIColor?
        let font: UIFont
        let insets: UIEdgeInsets
    }
    
    init(location: NavBarButtonLocation, side: NavBarButtonSide) {
        self.location = location
        self.side = side
        self.styles = NavBarButtonItem.getStyles(location: location, side: side)
        
        super.init()
        
        setupBackgroundColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class func getStyles(location: NavBarButtonLocation, side: NavBarButtonSide) -> Styles {
        let textColor: UIColor
        let backgroundColor: UIColor?
        let font: UIFont
        let insets: UIEdgeInsets
        switch ASAPP.styles.navBarStyles.buttonStyle {
        case .bubble:
            switch location {
            case .chat:
                textColor = ASAPP.styles.colors.navBarButtonForeground
                backgroundColor = ASAPP.styles.colors.navBarButtonBackground
            case .predictive:
                textColor = ASAPP.styles.colors.predictiveNavBarButtonForeground
                backgroundColor = ASAPP.styles.colors.predictiveNavBarButtonBackground
            }
            font = ASAPP.styles.textStyles.navButton.font
            insets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 11)
        case .text:
            switch location {
            case .chat:
                textColor = ASAPP.styles.colors.navBarButton
            case .predictive:
                textColor = ASAPP.styles.colors.predictiveNavBarButton
            }
            backgroundColor = nil
            font = ASAPP.styles.textStyles.navButton.font
            switch side {
            case .left:
                insets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 11)
            case .right:
                insets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 0)
            }
        }
        
        return Styles(textColor: textColor, backgroundColor: backgroundColor, font: font, insets: insets)
    }
    
    private func setupBackgroundColor() {
        guard let backgroundColor = styles.backgroundColor,
            let button = customView as? UIButton else {
                return
        }
        
        let style: NavBarButtonStyle = location == .chat ? .ask : .respond
        
        button.setBackgroundImage(
            NavBarButtonItem.getChatBubbleBackgroundImage(
                forStyle: style,
                color: backgroundColor,
                alpha: 1),
            for: .normal)
        button.setBackgroundImage(
            NavBarButtonItem.getChatBubbleBackgroundImage(
                forStyle: style,
                color: backgroundColor,
                alpha: 0.6),
            for: .highlighted)
    }
    
    private class func getChatBubbleBackgroundImage(forStyle style: NavBarButtonStyle, color: UIColor, alpha: CGFloat) -> UIImage? {
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
    
    @discardableResult
    func configTitle(_ title: String) -> Self {
        let button = UIButton()
        
        button.setAttributedTitle(NSAttributedString(string: title, attributes: [
            .font: styles.font,
            .foregroundColor: styles.textColor,
            .kern: ASAPP.styles.textStyles.navButton.letterSpacing
            ]), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: title, attributes: [
            .font: styles.font,
            .foregroundColor: styles.textColor.withAlphaComponent(0.6),
            .kern: ASAPP.styles.textStyles.navButton.letterSpacing
            ]), for: .highlighted)
        
        if let titleLabel = button.titleLabel {
            let titleSize = titleLabel.sizeThatFits(.zero)
            let buttonHeight = ceil(titleSize.height) + styles.insets.top + styles.insets.bottom
            let buttonWidth = ceil(titleSize.width) + styles.insets.left + styles.insets.right
            button.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        } else {
            button.titleEdgeInsets = styles.insets
            button.sizeToFit()
        }
        
        customView = button
        
        return self
    }
    
    @discardableResult
    func configImage(_ customImage: ASAPPNavBarButtonImage) -> Self {
        let button = SizedImageOnlyButton()
        button.imageView?.contentMode = .scaleAspectFit
        
        let tintColor = styles.backgroundColor != styles.textColor ? styles.textColor : .white
        button.setImage(customImage.image.tinted(tintColor, alpha: 1), for: .normal)
        button.setImage(customImage.image.tinted(tintColor, alpha: 0.6), for: .highlighted)
        
        var insets = customImage.insets
        switch side {
        case .left:
            insets.right += 6
        case .right:
            insets.left += 6
        }
        
        if styles.backgroundColor != nil {
            insets.left = max(6, insets.left)
            insets.right = max(6, insets.right)
        }
        
        button.imageSize = customImage.size
        button.contentEdgeInsets = .zero
        button.imageEdgeInsets = insets
        let buttonSize = CGSize(width: customImage.size.width + insets.left + insets.right,
                                height: customImage.size.height + insets.top + insets.bottom)
        button.frame = CGRect(x: 0, y: 0, width: buttonSize.width, height: buttonSize.height)
        
        customView = button
        
        return self
    }
    
    @discardableResult
    func configTarget(_ target: Any?, action: Selector) -> Self {
        guard let button = customView as? UIButton else {
            return self
        }
        
        button.addTarget(target, action: action, for: .touchUpInside)
        
        return self
    }
}
