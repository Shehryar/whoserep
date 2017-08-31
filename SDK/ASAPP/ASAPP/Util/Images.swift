//
//  Images.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum ASAPPIcon: String {
    case alertError = "iconAlertError"
    case alertWarning = "iconAlertWarning"
    case arrowBack = "iconArrowBack"
    case arrowOutgoing = "iconArrowOutgoing"
    case checkmarkCircle = "iconCheckmarkCircle"
    case checkmarkThick = "iconCheckmarkThick"
    case checkmarkThin = "iconCheckmarkThin"
    case clock = "iconClock"
    case loginKey = "iconLoginKey"
    case paperclip = "iconPaperclip"
    case power = "iconPower"
    case trash = "iconTrash"
    case user = "iconUser"
    case userMinus = "iconUserMinus"
    case xThick = "iconXThick"
    case xThin = "iconXThin"
}

extension UIImage {
    
    class func asappImage(named name: String) -> UIImage? {
        return UIImage(named: name, in: ASAPP.bundle, compatibleWith: nil)
    }
    
    class func asappIcon(_ icon: ASAPPIcon) -> UIImage? {
        return asappImage(named: icon.rawValue)
    }
}



class Images: NSObject {
    
    // MARK: Image Names
    
    enum ASAPPImage: String {
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
        case iconGuillemetRight = "icon-guillemet-right"
        case iconStar = "icon-star"
        case iconStarFilled = "icon-star-filled"
        case iconUser = "icon-user"
        
        case buttonAskBG = "button-bg-ask"
        case buttonRespondBG = "button-bg-respond"
        case buttonCloseBG = "button-bg-close"
        
        case tileImageDash = "bg-dash-tile"
        
        case imageEquipmentReturnMap = "map-equipment"
        case imageDeviceTrackingMap = "map-device"
        case imageTechLocationMap = "map-tech"
    }
    
    // MARK: Images
    
    class func asappImage(_ image: ASAPPImage) -> UIImage? {
        return imageWithName(image.rawValue)
    }

    private class func imageWithName(_ name: String) -> UIImage? {
        let image = UIImage(named: name, in: ASAPP.bundle, compatibleWith: nil)
        return image
    }
    
    // MARK: Gifs
    
    class func gifLoaderBar() -> UIImage? {
        var imageName: String
        if (UIScreen.main.scale > 1) {
            imageName = "gif-loader-bar@2x"
        } else {
            imageName = "gif-loader-bar"
        }
        
        if let imagePath = ASAPP.bundle.path(forResource: imageName, ofType: "gif") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) {
                return UIImage.sd_animatedGIF(with: data)
            }
        }
        
        return nil
    }
}



