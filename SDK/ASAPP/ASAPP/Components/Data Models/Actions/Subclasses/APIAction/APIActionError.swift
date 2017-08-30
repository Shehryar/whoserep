//
//  APIActionError.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class APIActionError: NSObject {

    let code: Int?
    
    let userMessage: String?
    
    let debugMessage: String?
    
    let invalidInputs: [String]?
    
    // MARK:- Init
    
    init(code: Int?,
         userMessage: String?,
         debugMessage: String?,
         invalidInputs: [String]?) {
        self.code = code
        self.userMessage = userMessage
        self.debugMessage = debugMessage
        self.invalidInputs = invalidInputs
        super.init()
    }
}

// MARK:- JSON Parsing

extension APIActionError {
 
    enum JSONKey: String {
        case code
        case userMessage
        case debugMessage
        case invalidInputs
    }
    
    class func fromJSON(_ json: Any?) -> APIActionError? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        
        let code = json.int(for: JSONKey.code.rawValue)
        let userMessage = json.string(for: JSONKey.userMessage.rawValue)
        let debugMessage = json.string(for: JSONKey.debugMessage.rawValue)
        let invalidInputs = json.strings(for: JSONKey.invalidInputs.rawValue)
        
        return APIActionError(code: code,
                              userMessage: userMessage,
                              debugMessage: debugMessage,
                              invalidInputs: invalidInputs)
    }
}
