//
//  AppSettings.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP


enum Environment: String {
    case asapp = "demo"
    case mitch = "mitch"
    case comcast = "comcast.preprod"
    case sprint = "sprint"
}

class AppSettings: NSObject {
    
    let environment: Environment
    
    let versionString: String
    
    var branding: Branding
    
    // MARK: Demo Settings
    
    var liveChatEnabled: Bool {
        didSet {
            if liveChatEnabled && !supportsLiveChat {
                liveChatEnabled = false
            }
        }
    }
    
    var demoContentEnabled: Bool
    
    var canUseDifferentCompany: Bool {
        switch environment {
        case .asapp, .mitch: return true
        case .comcast, .sprint: return false
        }
    }
    
    //
    // MARK:- Init
    //
    
    init(environment: Environment) {
        self.environment = environment
        switch environment {
        case .comcast:
            branding = Branding(brandingType: .xfinity)
            break
        
        case .sprint:
            branding = Branding(brandingType: .sprint)
            break
            
        case .mitch, .asapp:
            branding = Branding(brandingType: .asapp)
            break
        }
        
        // Version Info
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        self.versionString = "\(version) (\(build))"
        
        // Demo Settings
        self.demoContentEnabled = false
        self.liveChatEnabled = false
        super.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK:- Environment Settings

extension AppSettings {
    
    var asappEnvironment: ASAPPEnvironment {
        return .staging
    }
    
    var supportsLiveChat: Bool {
        return AppSettings.canDemoLiveChat(environment: environment)
    }

    var defaultCompany: String {
        return AppSettings.defaultCompanyForEnvironment(environment: environment)
    }
}

// MARK:- Presets

extension AppSettings {
    
    class func settingsFor(environment: Environment) -> AppSettings {
        return AppSettings(environment: environment)
    }
}

// MARK:- User Token

extension AppSettings {
    
    private func accountStorageKey() -> String {
        
        return "\(environment)-Demo-Account-Key"
    }
    
    func getCurrentAccount() -> UserAccount {
        if let savedAccount = UserAccount.getSavedAccount(withKey: accountStorageKey()) {
            return savedAccount
        }
        
        let account = UserAccount.newRandomAccount(company: defaultCompany)
        account.save(withKey: accountStorageKey())
        
        return account
    }
    
    func setCurrentAccount(account: UserAccount) {
        account.save(withKey: accountStorageKey())
    }
}

// MARK:- Static Environment Functions

extension AppSettings {
    
    static func defaultCompanyForEnvironment(environment: Environment) -> String {
        switch environment {
        case .asapp: return "asapp"
        case .mitch: return "mitch"
        case .comcast: return "comcast"
        case .sprint: return "sprint"
        }
    }
    
    static func canChangeColors(environment: Environment) -> Bool {
        return [Environment.asapp, Environment.mitch].contains(environment)
    }
    
    static func canDemoLiveChat(environment: Environment) -> Bool {
        return [Environment.asapp, Environment.mitch].contains(environment)
    }
    
    static func environmentAfter(environment: Environment) -> Environment {
        switch environment {
        case .asapp: return .mitch
        case .mitch: return .comcast
        case .comcast: return .sprint
        case .sprint: return .asapp
        }
    }
}

// MARK:- Auth + Context

extension AppSettings {
    
    func getContext() -> [String : Any] {
        return [
            "fake_context_key_1" : "fake_context_value_1",
            "fake_context_key_2" : "fake_context_value_2"
        ]
    }
    
    func getAuthData() -> [String : Any] {
        
        //        sleep(1) // Mimic slow response from Comcast
        
        return [
            ASAPP.AUTH_KEY_ACCESS_TOKEN : "asapp_ios_fake_access_token",
            ASAPP.AUTH_KEY_ISSUED_TIME : Date(),
            ASAPP.AUTH_KEY_EXPIRES_IN : 60 * 60
        ]
    }
}
