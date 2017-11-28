//
//  APIAction.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class APIAction: Action {

    // MARK: Properties
    
    enum JSONKey: String {
        case requestPath
    }
    
    let requestPath: String
    
    var tempRequestTopLevelParams = [String: Any]()
    
    // MARK: Init
    
    required init?(content: Any?) {
        guard let content = content as? [String: Any] else {
            return nil
        }
        guard let requestPath = content.string(for: JSONKey.requestPath.rawValue) else {
                DebugLog.w(caller: APIAction.self, "\(JSONKey.requestPath.rawValue) is required. \(content)")
                return nil
        }
        self.requestPath = requestPath
        
        super.init(content: content)
    }
}

typealias APIActionCompletion = ((_ action: APIAction?, _ errorMessage: String?) -> Void)
