//
//  OutgoingMessageSerializer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class OutgoingMessageSerializer: NSObject {
    
    // MARK: Pubic Properties
    
    var myId: Int = 0
    var issueId: Int = 0
    var sessionInfo: String?
    var targetCustomerToken: String?
    var customerTargetCompanyId: Int = 0
    
    // MARK: Private Properties
    
    private var currentRequestId = 1

    // MARK: Init 
    
    override init() {
        super.init()
    }
}

// MARK:- Public Instance Methods

extension OutgoingMessageSerializer {
    func createRequestString(withPath path: String, params: [String : AnyObject]? = nil) -> (requestString: String, requestId: Int) {
        let requestId = getNextRequestId()
        let paramsJSONString = jsonStringify(params ?? [:])
        let contextJSONString = jsonStringify(contextForRequest(withPath: path))

        return ("\(path)|\(requestId)|\(contextJSONString)|\(paramsJSONString)", requestId)
    }
}

// MARK: - Private Utility Methods

extension OutgoingMessageSerializer {
    private func getNextRequestId() -> Int {
        currentRequestId++
        return currentRequestId
    }
    
    private func jsonStringify(dictionary: [String : AnyObject]) -> String {
        guard NSJSONSerialization.isValidJSONObject(dictionary ?? [:]) else {
            DebugLogError("Dictionary is not valid JSON object: \(dictionary)")
            return ""
        }
        
        if let json = try? NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted) {
            if let jsonString = String(data: json, encoding: NSUTF8StringEncoding) {
                return jsonString
            }
            DebugLogError("Unable to create string from json: \(json)")
            return ""
        }
        
        DebugLogError("Unable to serialize dictionary as JSON: \(dictionary)")
        return ""
    }
    
    func requestWithPathIsCustomerEndpoint(path: String) -> Bool {
        return path.hasPrefix("customer/")
    }
    
    func contextForRequest(withPath path: String) -> [String : AnyObject] {
        var context = [ "CompanyId" : customerTargetCompanyId ]
        if !requestWithPathIsCustomerEndpoint(path) {
            if targetCustomerToken != nil {
                context = [ "IssueId" : issueId ]
            }
        }
        return context
    }
}
