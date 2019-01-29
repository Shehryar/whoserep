//
//  ASAPPViews.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Holds references to optional custom views.
 */
@objc(ASAPPViews)
@objcMembers
public class ASAPPViews: NSObject {
    
    /// The title view displayed in the navigation bar when viewing live chat. Overrides `ASAPPStrings.chatTitle`.
    public var chatTitle: UIView?
}