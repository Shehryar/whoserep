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
        var backgroundColor: UIColor?
        var imageSize: CGSize
        var imageInsets: UIEdgeInsets
    }
    
    init(location: NavBarButtonLocation, side: NavBarButtonSide) {
        self.location = location
        self.side = side
        self.styles = NavCloseBarButtonItem.getStyles(location: location, side: side)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private class func getStyles(location: NavBarButtonLocation, side: NavBarButtonSide) -> Styles {
        let closeButtonStyle = ASAPP.styles.navBarStyles.buttonImages.close
        var foregroundColor: UIColor
        var backgroundColor: UIColor?
        var imageSize = closeButtonStyle?.size ?? .zero
        var imageInsets = closeButtonStyle?.insets ?? .zero
        
        switch ASAPP.styles.navBarStyles.buttonStyle {
        case .bubble:
            switch location {
            case .chat:
                foregroundColor = ASAPP.styles.colors.navBarButtonForeground
                backgroundColor = ASAPP.styles.colors.navBarButtonBackground
            case .predictive:
                foregroundColor = ASAPP.styles.colors.predictiveNavBarButtonForeground
                backgroundColor = ASAPP.styles.colors.predictiveNavBarButtonBackground
            }
            
            imageSize = CGSize(width: 8, height: 8)
            imageInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
            
        case .text:
            foregroundColor = ASAPP.styles.colors.navBarButton
            backgroundColor = nil
            switch side {
            case .left:
                imageInsets.right += 6
            case .right:
                imageInsets.left += 6
            }
        }
        
        return Styles(foregroundColor: foregroundColor, backgroundColor: backgroundColor, imageSize: imageSize, imageInsets: imageInsets)
    }
    
    @discardableResult
    func configSegue(_ segue: ASAPPSegue) -> Self {
        let closeButtonStyle = ASAPP.styles.navBarStyles.buttonImages.close
        let backButtonStyle = ASAPP.styles.navBarStyles.buttonImages.back
        let button = SizedImageOnlyButton()
        button.imageView?.contentMode = .scaleAspectFit
        
        var image = closeButtonStyle?.image
        switch segue {
        case .present: break
        case .push:
            styles.foregroundColor = ASAPP.styles.colors.navBarButtonBackground
            styles.backgroundColor = nil
            image = backButtonStyle?.image
            styles.imageSize = backButtonStyle?.size ?? .zero
            styles.imageInsets = backButtonStyle?.insets ?? .zero
            styles.imageInsets.right += 6
        }
        
        button.setImage(image?.tinted(styles.foregroundColor, alpha: 1), for: .normal)
        button.setImage(image?.tinted(styles.foregroundColor, alpha: 0.6), for: .highlighted)
        button.imageSize = styles.imageSize
        
        // Bubble
        if let backgroundColor = styles.backgroundColor {
            button.setBackgroundImage(Images.asappImage(.buttonCloseBG)?.tinted(backgroundColor, alpha: 1), for: .normal)
            button.setBackgroundImage(Images.asappImage(.buttonCloseBG)?.tinted(backgroundColor, alpha: 0.6), for: .highlighted)
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
