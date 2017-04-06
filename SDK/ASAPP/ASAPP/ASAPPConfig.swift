//
//  ASAPPConfig.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

private let OLD_CLIENT_SECRET = "BD0ED4C975FF217D3FCD00A895130849E5521F517F0162F5D28D61D628B2B990"

// MARK:- ASAPPConfig

public class ASAPPConfig: NSObject {
    
    public let appId: String
    
    public let apiHostName: String
    
    public let clientId: String
    
    // MARK: Init
    
    public init(appId: String,
                apiHostName: String,
                clientId: String) {
        self.appId = appId
        self.apiHostName = apiHostName
        self.clientId = clientId
        super.init()
    }
}

// MARK:- DebugPrintable

public extension ASAPPConfig {
    
    override public var description: String {
        return "\(appId) @ \(apiHostName)"
    }
    
    override public var debugDescription: String {
        return description
    }
}

// MARK:- Hash Key

internal extension ASAPPConfig {
    
    func hashKey(with user: ASAPPUser, prefix: String? = nil) -> String {
        return "\(prefix ?? "")\(apiHostName))-\(appId)-cust-\(user.userIdentifier)-0"
    }
}
