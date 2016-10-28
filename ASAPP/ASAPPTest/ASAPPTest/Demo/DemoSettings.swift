//
//  DemoSettings.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/11/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

class DemoSettings: NSObject {

    // MARK:- Environment
    
    static let KEY_ENVIRONMENT = "ASAPP_DEMO_KEY_ENVIRONMENT"
    
    class func environmentString(environment: ASAPPEnvironment) -> String {
        switch environment {
        case .production: return "Production"
        case .staging: return "Staging"
        }
    }
    
    class func currentEnvironment() -> ASAPPEnvironment {
        if let storedEnvironmentString = UserDefaults.standard.string(forKey: KEY_ENVIRONMENT) {
            if storedEnvironmentString == environmentString(environment: .production) {
                return .production
            } else {
                return .staging
            }
        }
        return .staging
    }
    
    class func setCurrentEnvironment(environment: ASAPPEnvironment) {
        UserDefaults.standard.set(environmentString(environment: environment), forKey: KEY_ENVIRONMENT)
    }
    
    // MARK:- Phone Upgrade Eligibility
    
    static let KEY_PHONE_UPGRADE_INELIGIBLE = "ASAPP_DEMO_PHONE_UPGRADE_INELIGIBLE"
    
    class func ineligibleForPhoneUpgrade() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_PHONE_UPGRADE_INELIGIBLE)
    }
    
    class func setIneligibleForPhoneUpgrade(eligible: Bool) {
        UserDefaults.standard.set(eligible, forKey: KEY_PHONE_UPGRADE_INELIGIBLE)
    }
    
    // MARK:- Demo Content
    
    static let KEY_DEMO_CONTENT = "ASAPP_DEMO_CONTENT_ENABLED"
    
    class func demoContentEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_DEMO_CONTENT)
    }
    
    class func setDemoContentEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: KEY_DEMO_CONTENT)
    }
    
    // MARK:- Live Chat Demo
    
    static let KEY_DEMO_LIVE_CHAT = "ASAPP_DEMO_LIVE_CHAT"
    
    class func demoLiveChat() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_DEMO_LIVE_CHAT)
    }
    
    class func setDemoLiveChat(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: KEY_DEMO_LIVE_CHAT)
    }
    
    // MARK:- Force Comcast User
    
    static let KEY_FORCE_PHONE_USER = "ASAPP_DEMO_FORCE_PHONE_USER"
    
    class func useDemoPhoneUser() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_FORCE_PHONE_USER)
    }
    
    class func setUseDemoPhoneUser(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: KEY_FORCE_PHONE_USER)
    }
}
