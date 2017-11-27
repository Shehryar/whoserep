//
//  ASAPPShapeStyles.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Customizable shape styles.
 */
@objcMembers
public class ASAPPShapeStyles: NSObject {
    /// The width of the stroke of separators such as timestamp headers and chat bubble borders.
    public var separatorStrokeWidth: CGFloat = 1.0
    
    /// Whether primary Component buttons have rounded corners.
    public var primaryButtonsRounded = false
    
    /// The send button image. If nil, `ASAPPStrings.predictiveSendButton` or `ASAPPStrings.chatInputSend` is displayed instead.
    lazy public var sendButtonImage: ASAPPCustomImage? = {
        return ASAPPCustomImage(image: Images.getImage(.iconSend)!, size: CGSize(width: 26, height: 26))
    }()
}
