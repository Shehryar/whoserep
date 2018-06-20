//
//  ASAPPConstants.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK: - Public Constants: Demo

public extension ASAPP {
    
    private static var demoContentEnabled = false
    
    /// :nodoc:
    public class func isDemoContentEnabled() -> Bool {
        if isInternalBuild {
            return demoContentEnabled
        } else {
            return false
        }
    }
    
    /// :nodoc:
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

// MARK: - Internal Constants

internal extension ASAPP {
    
    internal static let clientTypeKey = "ASAPP-ClientType"
    
    internal static let clientType = "consumer-ios-sdk"
    
    internal static let clientVersionKey = "ASAPP-ClientVersion"
    
    internal static let clientSecretKey = "ASAPP-ClientSecret"
    
    internal static let partnerAppVersionKey = "ASAPP-PartnerAppVersion"
}
