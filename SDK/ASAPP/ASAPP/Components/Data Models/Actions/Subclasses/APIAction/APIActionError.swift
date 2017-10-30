//
//  APIActionError.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

struct InvalidInput {
    enum JSONKey: String {
        case name
        case userMessage
    }
    
    let name: String
    let userMessage: String?
}

extension InvalidInput {
    init?(_ dict: [String: String]) {
        guard let name = dict[JSONKey.name.rawValue] else {
            return nil
        }
        
        self.init(name: name, userMessage: dict[JSONKey.userMessage.rawValue])
    }
}

class APIActionError: NSObject {

    let code: Int?
    
    let userMessage: String?
    
    let debugMessage: String?
    
    let invalidInputs: [InvalidInput]?
    
    // MARK: - Init
    
    init(code: Int?,
         userMessage: String?,
         debugMessage: String?,
         invalidInputs: [InvalidInput]?) {
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
        let invalidInputsDict = dict[JSONKey.invalidInputs.rawValue] as? [[String: String]]
        let invalidInputs = invalidInputsDict?.map { return InvalidInput($0) }.flatMap { $0 }
        
        self.init(code: code,
                  userMessage: userMessage,
                  debugMessage: debugMessage,
                  invalidInputs: invalidInputs)
    }
}
