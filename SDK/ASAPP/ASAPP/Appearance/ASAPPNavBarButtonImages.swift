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
        return ASAPPCustomImage(image: Images.getImage(.iconX)!, size: CGSize(width: 13, height: 13), insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }()
    
    /// The back button appears in the top left when the view controller is pushed into a navigation stack. Defaults to a ‹.
    lazy public var back: ASAPPCustomImage? = {
        return ASAPPCustomImage(image: Images.getImage(.iconGuillemetLeft)!, size: CGSize(width: 16, height: 16), insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }()
    
    /// The ask button appears in the chat view when not chatting with an agent.
    public var ask: ASAPPCustomImage?
    
    /// The end chat button appears in the chat view when chatting with an agent.
    public var end: ASAPPCustomImage?
}
