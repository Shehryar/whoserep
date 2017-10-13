//
//  ASAPPNavBarButtonImages.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

@objcMembers
public class ASAPPNavBarButtonImages: NSObject {
    
    // MARK: Properties
    
    lazy public var close: ASAPPNavBarButtonImage? = {
        return ASAPPNavBarButtonImage(image: Images.getImage(.iconX)!, size: CGSize(width: 13, height: 13), insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }()
    
    lazy public var back: ASAPPNavBarButtonImage? = {
        return ASAPPNavBarButtonImage(image: Images.getImage(.iconGuillemetThinLeft)!, size: CGSize(width: 24, height: 24), insets: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }()
    
    public var ask: ASAPPNavBarButtonImage?
    
    public var backToChat: ASAPPNavBarButtonImage?
    
    public var end: ASAPPNavBarButtonImage?
}
