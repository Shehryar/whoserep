//
//  ASAPPNavBarButtonImages.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Customizable images for navigation bar buttons.
 */
@objc(ASAPPNavBarButtonImages)
@objcMembers
public class ASAPPNavBarButtonImages: NSObject {
    
    // MARK: Properties
    
    /// The close button appears in the top right when the view controller is presented modally. Defaults to an ✕.
    lazy public var close: ASAPPCustomImage? = {
        return ASAPPCustomImage(image: Images.getImage(.iconX)!, size: CGSize(width: 13, height: 13), insets: UIEdgeInsets(top: 15, left: 0, bottom: 16, right: 0))
    }()
    
    /// The back button appears in the top left when the view controller is pushed into a navigation stack. Defaults to a ‹.
    lazy public var back: ASAPPCustomImage? = {
        return ASAPPCustomImage(image: Images.getImage(.iconArrowLeft)!.tinted(ASAPP.styles.colors.dark, alpha: 0.9), size: CGSize(width: 14, height: 14), insets: UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
    }()
    
    /// The more button appears in the chat view when chatting with an agent and lets the user end the live chat. Defaults to a ⋮.
    lazy public var more: ASAPPCustomImage? = {
        return ASAPPCustomImage(image: Images.getImage(.iconMore)!, size: CGSize(width: 18, height: 18), insets: UIEdgeInsets(top: 13, left: 0, bottom: 13, right: 0))
    }()
}
