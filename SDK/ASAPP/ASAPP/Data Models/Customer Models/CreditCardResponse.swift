//
//  CreditCardResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/15/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class CreditCardResponse: NSObject {

    static let DEFAULT_ERROR_MESSAGE = ASAPP.strings.creditCardDefaultError
    
    let success: Bool
    
    let errorMessage: String?
    let nameErrorMessage: String?
    let numberErrorMessage: String?
    let expiryErrorMessage: String?
    let cvvErrorMessage: String?
    
    var invalidFields: [CreditCardField]? {
        var invalidFields = [CreditCardField]()
        if nameErrorMessage != nil {
            invalidFields.append(.name)
        }
        if numberErrorMessage != nil {
            invalidFields.append(.number)
        }
        if expiryErrorMessage != nil {
            invalidFields.append(.expiry)
        }
        if cvvErrorMessage != nil {
            invalidFields.append(.cvv)
        }
        
        return invalidFields.isEmpty ? nil : invalidFields
    }
    
    init(success: Bool,
         errorMessage: String? = nil,
         nameErrorMessage: String? = nil,
         numberErrorMessage: String? = nil,
         expiryErrorMessage: String? = nil,
         cvvErrorMessage: String? = nil) {
        self.success = success
        self.errorMessage = errorMessage
        self.nameErrorMessage = nameErrorMessage
        self.numberErrorMessage = numberErrorMessage
        self.expiryErrorMessage = expiryErrorMessage
        self.cvvErrorMessage = cvvErrorMessage
        super.init()
    }
    
    // MARK: Default Error Response
    
    class func defaultErrorResponse() -> CreditCardResponse {
        return CreditCardResponse(success: false, errorMessage: DEFAULT_ERROR_MESSAGE)
    }
}

// MARK: JSON Parsing

extension CreditCardResponse {
    
    class func from(json: Any?) -> CreditCardResponse {
        guard let json = json as? [String : Any] else {
            return defaultErrorResponse()
        }
        
        guard let success = json["Success"] as? Bool else {
            // success value not contained in the response
            return defaultErrorResponse()
        }
        
        let invalidFields = json["InvalidFields"] as? [String : AnyObject]
        
        var nameErrorMessage: String?
        var numberErrorMessage: String?
        var expiryErrorMessage: String?
        var cvvErrorMessage: String?
        
        if let nameError = invalidFields?[CreditCardField.name.rawValue] as? String {
            nameErrorMessage = nameError.isEmpty ? nil : nameError
        }
        if let numberError = invalidFields?[CreditCardField.number.rawValue] as? String {
            numberErrorMessage = numberError.isEmpty ? nil : numberError
        }
        if let expiryError = invalidFields?[CreditCardField.expiry.rawValue] as? String {
            expiryErrorMessage = expiryError.isEmpty ? nil : expiryError
        }
        if let cvvError = invalidFields?[CreditCardField.cvv.rawValue] as? String {
            cvvErrorMessage = cvvError.isEmpty ? nil : cvvError
        }
        
        return CreditCardResponse(
            success: success,
            errorMessage: json["ErrorMessage"] as? String,
            nameErrorMessage: nameErrorMessage,
            numberErrorMessage: numberErrorMessage,
            expiryErrorMessage: expiryErrorMessage,
            cvvErrorMessage: cvvErrorMessage)
    }
}
