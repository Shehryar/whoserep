//
//  SRSIconItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum SRSIcon: String {
    case creditCard = "creditCard"
}

class SRSIconItem: NSObject, JSONObject {

    let icon: SRSIcon
    
    func getImage() -> UIImage? {
        switch icon {
        case .creditCard: return Images.asappImage(.iconCreditCardMedium)
        }
    }
    
    // MARK: Init
    
    required init(icon: SRSIcon) {
        self.icon = icon
        super.init()
    }
    
    // MARK:- JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json,
            let iconString = json["icon"] as? String,
            let icon = SRSIcon(rawValue: iconString) else {
                return nil
        }
        
        return SRSIconItem(icon: icon)
    }
}
