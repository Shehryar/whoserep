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
        case iconCreditCard = "icon-credit-card"
        case iconCreditCardMedium = "icon-credit-card-medium"
        case iconErrorAlert = "icon-error-alert"
        case iconErrorAlertFilled = "icon-error-alert-filled"
        case iconExitLink = "icon-exit-link"
        case iconHideKeyboard = "icon-hide-keyboard"
        case iconMore = "icon-more"
        case iconNewQuestion = "icon-new-question"
        case iconPaperclip = "icon-paperclip"
        case iconSend = "icon-send"
        case iconSmallX = "icon-x-small"
        case iconStar = "icon-star"
        case iconStarFilled = "icon-star-filled"
        case iconUser = "icon-user"
        case iconX = "icon-x"
        
        case buttonCloseBG = "button-bg-close"
        
        case tileImageDash = "bg-dash-tile"
        
        case imageEquipmentReturnMap = "map-equipment"
        case imageDeviceTrackingMap = "map-device"
        case imageTechLocationMap = "map-tech"
    }
    
    class func getImage(_ icon: Icon) -> UIImage? {
        return UIImage(named: icon.rawValue, in: ASAPP.bundle, compatibleWith: nil)
    }
}
