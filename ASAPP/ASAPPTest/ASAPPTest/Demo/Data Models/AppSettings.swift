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
    
    var styles: ASAPPStyles
    
    let versionString: String
    
    // MARK: Logo
    
    var logoImage: UIImage?
    
    var logoImageSize: CGSize = CGSize(width: 140, height: 28)
        
    // MARK: Colors
    
    var backgroundColor: UIColor = UIColor.white
    
    var backgroundColor2: UIColor = UIColor(red:0.941, green:0.937, blue:0.949, alpha:1)
    
    var foregroundColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.263, alpha:1)
    
    var foregroundColor2: UIColor = UIColor(red:0.483, green:0.505, blue:0.572, alpha:1)
    
    var separatorColor: UIColor = UIColor(red:0.874, green:0.875, blue:0.874, alpha:1)
    
    var accentColor: UIColor = UIColor(red:0.266, green:0.808, blue:0.600, alpha:1)
    
    var navBarColor: UIColor = UIColor.white
    
    var navBarTintColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.265, alpha:1)
    
    var navBarTitleColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.263, alpha:1)
    
    var statusBarStyle: UIStatusBarStyle = .default
    
    // MARK: Fonts
    
    var lightFont: UIFont = DemoFonts.latoLightFont(withSize: 14)
    
    var regularFont: UIFont = DemoFonts.latoRegularFont(withSize: 14)
    
    var mediumFont: UIFont = DemoFonts.latoRegularFont(withSize: 14)
    
    var boldFont: UIFont = DemoFonts.latoBoldFont(withSize: 14)
    
    // MARK: Demo Settings
    
    var liveChatEnabled: Bool {
        didSet {
            if liveChatEnabled && !supportsLiveChat {
                liveChatEnabled = false
            }
        }
    }
    
    var demoContentEnabled: Bool
    
    //
    // MARK:- Init
    //
    
    init(environment: Environment, styles: ASAPPStyles?) {
        self.environment = environment
        self.styles = styles ?? ASAPPStyles()
        
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
        
        switch environment {
        case .asapp:
            let settings = AppSettings(environment: .asapp, styles: ASAPPStyles())
            settings.useLightNavStyle()
            settings.useLightContentStyle()
            return settings

            
        case .mitch:
            let settings = AppSettings(environment: .mitch, styles: ASAPPStyles())
            settings.useDarkNavStyle()
            settings.useDarkContentStyle()
            return settings
            
        case .comcast:
            let styles = ASAPP.stylesForCompany(AppSettings.defaultCompanyForEnvironment(environment: .comcast))
            let settings = AppSettings(environment: .comcast, styles: styles)
            settings.logoImage = UIImage(named: "comcast-logo")
            settings.logoImageSize = CGSize(width: 140, height: 28)

            // Nav Bar Colors
            settings.navBarColor = UIColor(red:0.074, green:0.075, blue:0.074, alpha:1)
            settings.navBarTintColor = UIColor.white
            settings.navBarTitleColor = UIColor.white
            settings.statusBarStyle = .lightContent
            
            // Colors
            settings.foregroundColor = UIColor(red:0.027, green:0.027, blue:0.027, alpha:1)
            settings.foregroundColor2 = UIColor(red:0.580, green:0.580, blue:0.580, alpha:1)
            settings.backgroundColor = UIColor.white
            settings.backgroundColor2 = UIColor(red:0.898, green:0.898, blue:0.898, alpha:1)
            settings.separatorColor = UIColor(red:0.772, green:0.773, blue:0.772, alpha:1)
            settings.accentColor = UIColor(red:1, green:0.216, blue:0.212, alpha:1)
            
            // Fonts
            settings.lightFont = DemoFonts.xfinitySansLgtFont()
            settings.regularFont = DemoFonts.xfinitySansRegFont()
            settings.mediumFont = DemoFonts.xfinitySansMedFont()
            settings.boldFont = DemoFonts.xfinitySansBoldFont()
            
            return settings
            
        case .sprint:
            let styles = ASAPP.stylesForCompany(AppSettings.defaultCompanyForEnvironment(environment: .comcast))
            let settings = AppSettings(environment: .sprint, styles: styles)
            settings.logoImage = UIImage(named: "sprint-logo")
            settings.logoImageSize = CGSize(width: 140, height: 36)

            // Nav Bar Colors
            settings.navBarTintColor = UIColor.darkGray
            settings.navBarTitleColor = UIColor.black
            
            // Colors
            settings.foregroundColor = UIColor(red:0, green:0, blue:0, alpha:1)
            settings.foregroundColor2 = UIColor(red:0.490, green:0.490, blue:0.490, alpha:1)
            settings.backgroundColor = UIColor.white
            settings.separatorColor = UIColor(red:0.882, green:0.882, blue:0.882, alpha:1)
            settings.accentColor = UIColor(red:0.989, green:0.811, blue:0.003, alpha:1)
            
            // Fonts
            settings.lightFont = DemoFonts.sprintSansRegularFont()
            settings.regularFont = DemoFonts.sprintSansRegularFont()
            settings.mediumFont = DemoFonts.sprintSansMediumFont()
            settings.boldFont = DemoFonts.sprintSansBoldFont()
            
            return settings
        }
    }
}

// MARK:- Color Schemes

extension AppSettings {
    
    var canChangeColors: Bool {
        return AppSettings.canChangeColors(environment: environment)
    }
    
    // MARK: Nav Bar
    
    var isDarkNavStyle: Bool {
        return navBarColor.isDark()
    }
    
    func useLightNavStyle() {
        guard canChangeColors else { return }
        
        logoImage = UIImage(named: "asapp-logo")
        logoImageSize = CGSize(width: 100, height: 22)
        
        navBarColor = UIColor.white
        navBarTintColor = UIColor(red:0.220, green:0.231, blue:0.265, alpha:1)
        navBarTitleColor = UIColor(red:0.220, green:0.231, blue:0.263, alpha:1)
        statusBarStyle = .default
    }
    
    func useDarkNavStyle() {
        guard canChangeColors else { return }
        
        logoImage = UIImage(named: "asapp-logo-light")
        logoImageSize = CGSize(width: 100, height: 22)
        
        navBarColor = UIColor.black
        navBarTintColor = UIColor.white
        navBarTitleColor = UIColor.white
        statusBarStyle = .lightContent
    }
    
    // MARK: Content
    
    var isDarkContentStyle: Bool  {
        return backgroundColor.isDark()
    }
    
    func useLightContentStyle() {
        guard canChangeColors else { return }
        
        styles = ASAPPStyles()
        
        //styles.asappButtonBackgroundColor = UIColor(red:0.03, green:0.114, blue:0.18, alpha:1)
        styles.asappButtonBackgroundColor = UIColor(red:0.22, green:0.23, blue:0.24, alpha:1)
        styles.asappButtonForegroundColor = UIColor.white
        
        backgroundColor = UIColor.white
        backgroundColor2 = UIColor(red:0.941, green:0.937, blue:0.949, alpha:1)
        foregroundColor = UIColor(red:0.220, green:0.231, blue:0.263, alpha:1)
        foregroundColor2 = UIColor(red:0.483, green:0.505, blue:0.572, alpha:1)
        separatorColor = UIColor(red:0.874, green:0.875, blue:0.874, alpha:1)
        accentColor = UIColor(red:0.10, green:0.33, blue:0.52, alpha:1)
    }
    
    func useDarkContentStyle() {
        guard canChangeColors else { return }
        
        styles = ASAPPStyles.darkStyles()
        
        styles.asappButtonBackgroundColor = UIColor(red:0.266, green:0.808, blue:0.600, alpha:1)
        styles.asappButtonForegroundColor = UIColor(red:0.015, green:0.051, blue:0.080, alpha:1)
        
        backgroundColor = UIColor(red:0.015, green:0.051, blue:0.080, alpha:1)
        backgroundColor2 = UIColor(red: 0.07, green: 0.09, blue: 0.1, alpha: 1)
        foregroundColor = UIColor.white
        foregroundColor2 = UIColor(red:0.346, green:0.392, blue:0.409, alpha:1)
        separatorColor = UIColor(red:0.15, green:0.18, blue:0.19, alpha:1)
        accentColor = UIColor(red:0.266, green:0.808, blue:0.600, alpha:1)
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
