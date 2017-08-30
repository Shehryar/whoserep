//
//  SocketRequest.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SocketRequest {
    
    let requestId: Int
    let path: String
    let params: [String : Any]?
    let context: [String : Any]?
    let requestData: Data?
    let requestUUID: String
    
    required init(requestId: Int, path: String, params: [String : Any]?, context: [String : Any]?, requestData: Data?) {
        let uuid = UUID().uuidString
        
        self.requestUUID = uuid
        self.requestId = requestId
        self.path = path
        self.params = [ "RequestId": uuid ].with(params)
        self.context = context
        self.requestData = requestData
    }
}

// MARK:- Logging Utilities

extension SocketRequest {
    
    var containsSensitiveData: Bool {
        return path.contains("CreditCard")
    }
    
    func getParametersCleanedOfSensitiveData() -> [String : Any] {
        var cleanedParams = [String: Any]()
        cleanedParams.add(params)
        if path.contains("CreditCard") {
            if cleanedParams["Number"] != nil {
                cleanedParams["Number"] = "xxxx"
            }
            if cleanedParams["CVV"] != nil {
                cleanedParams["CVV"] = "xxx"
            }
            
        }
        
        return cleanedParams
    }
    
    func getLoggableDescription() -> String {
        let cleanedParams = getParametersCleanedOfSensitiveData()
        let paramsJSONString = JSONUtil.stringify(cleanedParams, prettyPrinted: true) ?? "{}"
        let contextJSONString = JSONUtil.stringify((context ?? [:]), prettyPrinted: true) ?? "{}"
        
        return "\(path)|\(requestId)|\(contextJSONString)|\(paramsJSONString)"
    }
    
    func logRequest(with requestString: String) {
        let loggableRequestString: String
        if containsSensitiveData {
            loggableRequestString = getLoggableDescription()
        } else {
            loggableRequestString = requestString
        }
        DebugLog.d("Sending request:\n\n\(loggableRequestString)")
    }
}
