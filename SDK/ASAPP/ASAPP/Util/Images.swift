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
        case iconX = "icon-x"
        case iconSmallX = "icon-x-small"
        case iconExitLink = "icon-exit-link"
        case iconBack = "icon-back"
        case iconCheckmark = "icon-checkmark"
        case iconCreditCard = "icon-credit-card"
        case iconCreditCardMedium = "icon-credit-card-medium"
        case iconErrorAlert = "icon-error-alert"
        case iconErrorAlertFilled = "icon-error-alert-filled"
        case iconHideKeyboard = "icon-hide-keyboard"
        case iconArrowLeft = "icon-arrow-left"
        case iconGuillemetLeft = "icon-guillemet-left"
        case iconPaperclip = "icon-paperclip"
        case iconSend = "icon-send"
        case iconStar = "icon-star"
        case iconStarFilled = "icon-star-filled"
        case iconUser = "icon-user"
        
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
