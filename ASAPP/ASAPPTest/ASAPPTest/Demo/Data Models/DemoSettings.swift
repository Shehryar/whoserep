//
//  DemoSettings.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/11/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

let NotificationDemoSettingsUpdate = Notification(name: Notification.Name(rawValue: "DemoSettingsUpdate"))

// MARK:- Environment

class DemoSettings: NSObject {
    
    class func currentEnvironment() -> ASAPPEnvironment {
        switch demoEnvironment() {
        case .staging, .demo, .demo2: return .staging
        case .production: return .production
        }
    }
}

// MARK:- Demo Environment

enum DemoEnvironment: String {
    case staging = "staging"
    case production = "production"
    case demo = "demo"
    case demo2 = "demo2"
}

func DemoEnvironmentDescription(environment: DemoEnvironment, withCompany company: Company) -> String {
    switch company {
    case .comcast:
        switch environment {
        case .staging: return "comcast.preprod"
        case .production: return "comcast"
        case .demo: return "comcast-demo"
        default: break
        }
        break
        
    case .sprint:
        switch environment {
        case .staging, .production: return "sprint"
        default: break
        }
        
    case .asapp, .asapp2:
        switch environment {
        case .demo, .production, .staging: return "demo"
        case .demo2: return "demo2"
        }
    }
    
    return "unknown"
}

extension DemoSettings {
    
    static let KEY_DEMO_ENVIRONMENT = "ASAPP_DEMO_KEY_DEMO_ENVIRONMENT"
    
    class func demoEnvironment() -> DemoEnvironment {
        if let envString = UserDefaults.standard.string(forKey: KEY_DEMO_ENVIRONMENT),
            let environment = DemoEnvironment(rawValue: envString) {
            return environment
        }
        return .demo
    }
    
    class func setDemoEnvironment(environment: DemoEnvironment) {
        UserDefaults.standard.set(environment.rawValue, forKey: KEY_DEMO_ENVIRONMENT)
    }
}

// MARK:- Demo Content

extension DemoSettings {
    static let KEY_DEMO_CONTENT = "ASAPP_DEMO_CONTENT_ENABLED"
    
    class func demoContentEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_DEMO_CONTENT)
    }
    
    class func setDemoContentEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: KEY_DEMO_CONTENT)
        
        postUpdateNotification()
    }
}

// MARK:- Live Chat Demo

extension DemoSettings {

    static let KEY_DEMO_LIVE_CHAT = "ASAPP_DEMO_LIVE_CHAT"
    
    class func demoLiveChat() -> Bool {
        return UserDefaults.standard.bool(forKey: KEY_DEMO_LIVE_CHAT)
    }
    
    class func setDemoLiveChat(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: KEY_DEMO_LIVE_CHAT)
        
        postUpdateNotification()
    }
}

// MARK:- Notifications

extension DemoSettings {
    
    fileprivate class func postUpdateNotification() {
        NotificationCenter.default.post(NotificationDemoSettingsUpdate)
    }
}
