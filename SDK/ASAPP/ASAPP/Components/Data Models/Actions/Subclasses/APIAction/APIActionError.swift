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
    
    let invalidInputs: [String: String]?
    
    // MARK: - Init
    
    init(code: Int?,
         userMessage: String?,
         debugMessage: String?,
         invalidInputs: [String: String]?) {
        self.code = code
        self.userMessage = userMessage
        self.debugMessage = debugMessage
        self.invalidInputs = invalidInputs
        super.init()
    }
}

// MARK: - JSON Parsing

extension APIActionError {
 
    enum JSONKey: String {
        case code
        case userMessage
        case debugMessage
        case invalidInputs
    }
    
    convenience init?(_ dict: [String: Any]?) {
        guard let dict = dict else {
            return nil
        }
        
        let code = dict.int(for: JSONKey.code.rawValue)
        let userMessage = dict.string(for: JSONKey.userMessage.rawValue)
        let debugMessage = dict.string(for: JSONKey.debugMessage.rawValue)
        let invalidInputs = dict[JSONKey.invalidInputs.rawValue] as? [String: String]
        
        self.init(code: code,
                  userMessage: userMessage,
                  debugMessage: debugMessage,
                  invalidInputs: invalidInputs)
    }
}
