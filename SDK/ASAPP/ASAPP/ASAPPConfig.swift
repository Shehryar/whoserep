//
//  ASAPPConfig.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK: - ASAPPConfig

/**
 Configuration for the SDK's connection to the API.
 */
@objcMembers
public class ASAPPConfig: NSObject {
    // MARK: - Properties
    
    /// Your app identifier.
    public let appId: String
    
    /// Host name for connecting to the API.
    public let apiHostName: String
    
    /// Your app's client secret.
    public let clientSecret: String
    
    /// Your app's region code.
    public let regionCode: String
    
    internal var identifierType: String {
        return "\(appId)_CUSTOMER_ACCOUNT_ID"
    }
    
    // MARK: Init
    
    /**
     Creates an instance of `ASAPPConfig` with the given parameters.
     
     - parameter appId: Your app identifier. Also known as the company marker.
     - parameter apiHostName: Host name for connecting to the API.
     - parameter clientSecret: Your app's client secret used when connecting to the API.
     - parameter regionCode: Your app's region code. Defaults to "US".
     */
    public init(appId: String,
                apiHostName: String,
                clientSecret: String,
                regionCode: String = "US") {
        self.appId = appId
        self.apiHostName = apiHostName
        self.clientSecret = clientSecret
        self.regionCode = regionCode
        super.init()
    }
}

// MARK: - DebugPrintable

public extension ASAPPConfig {
    /// :nodoc:
    override public var description: String {
        return "\(appId) @ \(apiHostName)"
    }
    
    /// :nodoc:
    override public var debugDescription: String {
        return description
    }
}

// MARK: - Hash Key

internal extension ASAPPConfig {
    
    func hashKey(with user: ASAPPUser, prefix: String? = nil) -> String {
        return "\(prefix ?? "")\(apiHostName))-\(appId)-cust-\(user.userIdentifier)-0"
    }
}
