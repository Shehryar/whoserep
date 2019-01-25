//
//  NavCloseBarButtonItem.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 10/11/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class NavCloseBarButtonItem: UIBarButtonItem {
    
    private var styles: Styles
    private let side: NavBarButtonSide
    private let location: NavBarButtonLocation
    
    private struct Styles {
        var foregroundColor: UIColor
        var activeColor: UIColor
        var backgroundColor: UIColor?
        var imageSize: CGSize
        var imageInsets: UIEdgeInsets
    }
    
    init(location: NavBarButtonLocation, side: NavBarButtonSide) {
        self.location = location
        self.side = side
        self.styles = NavCloseBarButtonItem.getStyles(location: location, side: side)
        super.init()
        
        accessibilityLabel = ASAPPLocalizedString("Close")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private class func getStyles(location: NavBarButtonLocation, side: NavBarButtonSide) -> Styles {
        let closeButtonStyle = ASAPP.styles.navBarStyles.buttonImages.close
        let backgroundColor: UIColor? = nil
        let imageSize = closeButtonStyle?.size ?? .zero
        let imageInsets = closeButtonStyle?.insets ?? .zero

        let foregroundColor = ASAPP.styles.colors.navBarButton
        let activeColor = ASAPP.styles.colors.navBarButtonActive
        
        return Styles(foregroundColor: foregroundColor, activeColor: activeColor, backgroundColor: backgroundColor, imageSize: imageSize, imageInsets: imageInsets)
    }
    
    @discardableResult
    func configSegue(_ segue: Segue) -> Self {
        let closeButtonStyle = ASAPP.styles.navBarStyles.buttonImages.close
        let backButtonStyle = ASAPP.styles.navBarStyles.buttonImages.back
        let button = SizedImageOnlyButton()
        button.imageView?.contentMode = .scaleAspectFit
        
        let image: UIImage?
        switch segue {
        case .present:
            image = closeButtonStyle?.image
            styles.imageSize = closeButtonStyle?.size ?? .zero
            styles.imageInsets = closeButtonStyle?.insets ?? .zero
        case .push:
            image = backButtonStyle?.image
            styles.imageSize = backButtonStyle?.size ?? .zero
            styles.imageInsets = backButtonStyle?.insets ?? .zero
        }
        
        switch side {
        case .left:
            styles.imageInsets.right += 40
        case .right:
            styles.imageInsets.left += 40
        }
        
        styles.foregroundColor = ASAPP.styles.colors.navBarButton
        styles.backgroundColor = nil
        
        button.setImage(image?.tinted(styles.foregroundColor, alpha: styles.foregroundColor.cgColor.alpha), for: .normal)
        button.setImage(image?.tinted(styles.activeColor, alpha: styles.activeColor.cgColor.alpha), for: .highlighted)
        button.imageSize = styles.imageSize
        
        // Bubble
        if let backgroundColor = styles.backgroundColor {
            button.setBackgroundImage(Images.getImage(.buttonCloseBG)?.tinted(backgroundColor, alpha: 1), for: .normal)
            button.setBackgroundImage(Images.getImage(.buttonCloseBG)?.tinted(backgroundColor, alpha: 0.6), for: .highlighted)
        }
        
        // Sizing
        button.contentEdgeInsets = .zero
        button.imageEdgeInsets = styles.imageInsets
        let buttonSize = CGSize(width: styles.imageSize.width + styles.imageInsets.left + styles.imageInsets.right,
                                height: styles.imageSize.height + styles.imageInsets.top + styles.imageInsets.bottom)
        
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
