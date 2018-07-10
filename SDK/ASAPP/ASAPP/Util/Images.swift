//
//  Images.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class Images: NSObject {
    enum Icon: String {
        case iconArrowLeft = "icon-arrow-left"
        case iconCheckmark = "icon-checkmark"
        case iconChevron = "icon-chevron"
        case iconDropdownChevron = "icon-dropdown-chevron"
        case iconErrorAlert = "icon-error-alert"
        case iconExitLink = "icon-exit-link"
        case iconMore = "icon-more"
        case iconNewQuestion = "icon-new-question"
        case iconPaperclip = "icon-paperclip"
        case iconSend = "icon-send"
        
        case buttonCloseBG = "button-bg-close"
    }
    
    class func getImage(_ icon: Icon) -> UIImage? {
        return UIImage(named: icon.rawValue, in: ASAPP.bundle, compatibleWith: nil)
    }
}
