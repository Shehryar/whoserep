//
//  DemoSettings.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/11/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class DemoSettings: NSObject {
    
    static let KEY_DEMO_SUBDOMAIN = "ASAPP_KEY_DEMO_SUBDOMAIN"
    static let KEY_DEMO_CONTENT   = "ASAPP_KEY_DEMO_CONTENT"
    
    // MARK:- Public Methods: SET
    
    class func applySettings(for appSettings: AppSettings) {
        
        // Demo Content
        UserDefaults.standard.set(appSettings.demoContentEnabled, forKey: KEY_DEMO_CONTENT)
     
        // Subdomain
        UserDefaults.standard.set(appSettings.subdomain, forKey: KEY_DEMO_SUBDOMAIN)
    }
    
    class func isDemoContentEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_DEMO_CONTENT)
    }
}
