//
//  ASAPPConstants.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- Public Constants

public extension ASAPP {
    
    public static let authTokenKey = "access_token"
    
    public static var clientVersion: String {
        if let bundleVersion = ASAPP.bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return bundleVersion
        }
        return "3.0.0"
    }
}

// MARK:- Public Constants: Demo

public extension ASAPP {
    
    private static var demoContentEnabled = false
    
    public class func isDemoContentEnabled() -> Bool {
        if isInternalBuild {
            return demoContentEnabled
        } else {
            return false
        }
    }
    
    public class func setDemoContentEnabled(_ enabled: Bool) {
        if isInternalBuild {
            demoContentEnabled = enabled
            DebugLog.d("Demo Content: \(enabled)")
        } else {
            DebugLog.e("Demo Content Disabled")
        }
    }

    // MARK: Internal Build
    
    internal static var isInternalBuild: Bool {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            return bundleIdentifier.contains("com.asappinc.")
        }
        return false
    }
}

// MARK:- Internal Constants

internal extension ASAPP {
    
    internal static let clientTypeKey = "ASAPP-ClientType"
    
    internal static let clientType = "consumer-ios-sdk"
    
    internal static let clientVersionKey = "ASAPP-ClientVersion"
    
    internal static let clientSecretKey = "ASAPP-ClientSecret"
}
