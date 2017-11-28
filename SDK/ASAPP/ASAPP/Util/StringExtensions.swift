//
//  StringExtensions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 11/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

extension String {
    
    var isLikelyASAPPPhoneNumber: Bool {
        let unallowedCharacterSet = CharacterSet(charactersIn: "+0123456789").inverted
        
        // Example: +13126089137
        if 9 ... 15 ~= self.count &&
            self.rangeOfCharacter(from: unallowedCharacterSet) == nil {
            return true
        }
 
        return false
    }
}
