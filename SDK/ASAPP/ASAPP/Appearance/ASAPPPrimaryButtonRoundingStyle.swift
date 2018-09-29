//
//  ASAPPPrimaryButtonRoundingStyle.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/29/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

/**
 Defines the corner rounding style of primary Component buttons.
 */
@objc(ASAPPPrimaryButtonRoundingStyle)
@objcMembers
public class ASAPPPrimaryButtonRoundingStyle: NSObject {
    /// Fully rounded, equivalent to a radius of half the height of the button
    public static var pill = ASAPPPrimaryButtonRoundingStyle(pill: true, radius: nil)
    
    /// Custom corner radius
    public static func radius(_ value: Int) -> ASAPPPrimaryButtonRoundingStyle {
        return ASAPPPrimaryButtonRoundingStyle(pill: false, radius: value)
    }
    
    internal var pill: Bool = false
    internal var radius: Int?
    
    private init(pill: Bool, radius: Int?) {
        self.pill = pill
        self.radius = radius
    }
}
