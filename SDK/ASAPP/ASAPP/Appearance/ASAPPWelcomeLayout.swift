//
//  ASAPPWelcomeLayout.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Represents the layout style of the welcome page.
 */
@objc
public enum ASAPPWelcomeLayout: Int {
    /// The welcome page options will appear as a top-left-aligned list of buttons.
    case buttonMenu = 0
    
    /// The welcome page options will appear as a bottom-right-aligned list of selectable chat messages.
    case chat = 1
}
