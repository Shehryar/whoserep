//
//  DemoSettings.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/11/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class DemoSettings: NSObject {
    
    static let KEY_DEMO_ENVIRONMENT_PREFIX  = "ASAPP_DEMO_ENVIRONMENT_PREFIX"
    static let KEY_DEMO_CONTENT             = "ASAPP_DEMO_CONTENT_ENABLED"
    static let KEY_DEMO_LIVE_CHAT           = "ASAPP_DEMO_LIVE_CHAT"
    
    // MARK:- Public Methods: SET
    
    class func applySettings(for appSettings: AppSettings) {
        
        // Environment Prefix
        if appSettings.environmentPrefix != .unknown {
            UserDefaults.standard.set(appSettings.environmentPrefix.rawValue, forKey: KEY_DEMO_ENVIRONMENT_PREFIX)
        } else {
            UserDefaults.standard.removeObject(forKey: KEY_DEMO_ENVIRONMENT_PREFIX)
        }
        
        // Demo Content
        UserDefaults.standard.set(appSettings.demoContentEnabled, forKey: KEY_DEMO_CONTENT)
     
        // Live Chat
        UserDefaults.standard.set(appSettings.liveChatEnabled, forKey: KEY_DEMO_LIVE_CHAT)
    }
    
    // MARK:- Public Methods: GET
    
    class func environmentPrefix() -> EnvironmentPrefix {
        if let stringValue = UserDefaults.standard.string(forKey: KEY_DEMO_ENVIRONMENT_PREFIX),
            let environmentPrefix = EnvironmentPrefix(rawValue: stringValue) {
            return environmentPrefix
        }
        return .unknown
    }
    
    class func isDemoContentEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_DEMO_CONTENT)
    }

    class func isLiveChatEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_DEMO_LIVE_CHAT)
    }
}
