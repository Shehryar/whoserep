//
//  CreditCard.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum CreditCardField: String {
    case name = "Name"
    case number = "CardNumber"
    case expiry = "Expiry"
    case cvv = "CVV"
}

class CreditCard: NSObject {
    
    var name: String?
    
    var number: String?
    
    var expiry: String? /* MM/YY */
    
    var cvv: String?
    
    // MARK: Read-only Properties
    
    var isValid: Bool {
        return getInvalidFields() == nil
    }
    
    // MARK: Init
    
    init(name: String?, number: String?, expiry: String?, cvv: String?) {
        self.name = name
        self.number = number
        self.expiry = expiry
        self.cvv = cvv
        super.init()
    }
    
    // MARK: Utility
    
    func getExpiryComponents() -> (/* month */ Int, /* year */ Int)? {
        guard let expiryComponents = expiry?.components(separatedBy: "/") else {
            return nil
        }
        guard expiryComponents.count == 2 else {
            return nil
        }
        guard let monthInt = Int(expiryComponents[0]),
            let yearInt = Int(expiryComponents[1]) else {
            return nil
        }
        
        return (monthInt, yearInt)
    }
    
    func getInvalidFields() -> [CreditCardField]? {
        var invalidFields = [CreditCardField]()

        /**
         Some credit card rules
         http://www.freeformatter.com/credit-card-number-generator-validator.html
         */
        
        //
        // Name
        //
        if let name = name {
            // Name is required
            if name.isEmpty {
                invalidFields.append(.name)
            }
        } else {
            invalidFields.append(.name)
        }
        
        //
        // Number
        //
        if let number = number {
            // Valid credit card numbers are 13-19 digits
            if number.characters.count < 13 || number.characters.count > 19 {
                invalidFields.append(.number)
            }
        } else {
            invalidFields.append(.number)
        }
        
        //
        // Expiry
        //
        if let (expiryMonth, _) = getExpiryComponents() {
            // Expiry month must be a valid month
            if expiryMonth < 1 || expiryMonth > 12 {
                invalidFields.append(.expiry)
            }
            
            // Assume year is fine
        } else {
            invalidFields.append(.expiry)
        }
        
        //
        // CVV
        //
        if let cvv = cvv {
            // CVV must be at least 3 digits long
            if cvv.characters.count < 3 {
                invalidFields.append(.cvv)
            }
        } else {
            invalidFields.append(.cvv)
        }
    
        
        return invalidFields.count > 0 ? invalidFields : nil
    }
    
    // MARK: Params Helper
    
    func toASAPPParams() -> [String : AnyObject]? {
        guard let name = name,
            let number = number,
            let expiry = expiry,
            let cvv = cvv else {
            return nil
        }
        
        return [
            CreditCardField.name.rawValue : name as AnyObject,
            CreditCardField.number.rawValue : number as AnyObject,
            CreditCardField.expiry.rawValue : expiry as AnyObject,
            CreditCardField.cvv.rawValue : cvv as AnyObject
        ]
    }
}
