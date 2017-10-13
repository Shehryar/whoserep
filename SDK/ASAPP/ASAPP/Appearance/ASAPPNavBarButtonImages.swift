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
@objcMembers
public class ASAPPNavBarButtonImages: NSObject {
    
    // MARK: Properties
    
    /// The close button appears in the top right when the view controller is presented modally. Defaults to an ✕.
    lazy public var close: ASAPPNavBarButtonImage? = {
        return ASAPPNavBarButtonImage(image: Images.getImage(.iconX)!, size: CGSize(width: 13, height: 13), insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }()
    
    /// The back button appears in the top left when the view controller is pushed into a navigation stack. Defaults to a ‹.
    lazy public var back: ASAPPNavBarButtonImage? = {
        return ASAPPNavBarButtonImage(image: Images.getImage(.iconGuillemetThinLeft)!, size: CGSize(width: 24, height: 24), insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }()
    
    /// The ask button appears in the chat view when not chatting with an agent.
    public var ask: ASAPPNavBarButtonImage?
    
    /// The back to chat button appears in the predictive view.
    public var backToChat: ASAPPNavBarButtonImage?
    
    /// The end chat button appears in the chat view when chatting with an agent.
    public var end: ASAPPNavBarButtonImage?
}
