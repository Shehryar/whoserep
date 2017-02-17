//
//  AppSettings.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

class AppSettings: NSObject {
    
    var subdomain: String {
        didSet {
            AppSettings.saveSubdomain(subdomain)
        }
    }
    
    var defaultCompany: String {
        didSet {
            AppSettings.saveDefaultCompany(defaultCompany)
        }
    }
    
    let versionString: String
    
    var branding: Branding
    
    //
    // MARK:- Init
    //
    
    init(subdomain: String?, defaultCompany: String?, branding: Branding? = nil) {
        let nonNilSubdomain = subdomain ?? SubdomainPreset.asapp.rawValue
        self.subdomain = nonNilSubdomain
        self.defaultCompany = defaultCompany ?? CompanyPreset.defaultCompanyFor(subdomain: nonNilSubdomain).rawValue
        
        if let branding = branding {
            self.branding = branding
        } else if let subdomainPreset = SubdomainPreset(rawValue: self.subdomain) {
            switch subdomainPreset {
            case .comcast:
                self.branding = Branding(brandingType: .xfinity)
                break
            
            case .sprint:
                self.branding = Branding(brandingType: .sprint)
                break
                
            case .mitch, .asapp:
                self.branding = Branding(brandingType: .asapp)
                break
            }
        } else {
            self.branding = Branding(brandingType: .asapp)
        }
        
        // Version Info
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        self.versionString = "\(version) (\(build))"
        
        // Demo Settings
        super.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK:- User Token

extension AppSettings {
    
    private func accountStorageKey() -> String {
        return "\(subdomain)-Demo-Account-Key"
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

// MARK:- Saving: Subdomain

extension AppSettings {
    private static let KEY_SUBDOMAIN = "ASAPP_DEMO_KEY_SUBDOMAIN"
    
    class func saveSubdomain(_ subdomain: String) {
        UserDefaults.standard.set(subdomain, forKey: KEY_SUBDOMAIN)
        UserDefaults.standard.synchronize()
    }
    
    class func getSavedSubdomain() -> String? {
        return UserDefaults.standard.string(forKey: KEY_SUBDOMAIN)
    }
}

// MARK:- Saving: Default Company

extension AppSettings {
    private static let KEY_DEFAULT_COMPANY = "ASAPP_DEMO_KEY_DEFAULT_COMPANY"
    
    class func saveDefaultCompany(_ company: String) {
        UserDefaults.standard.set(company, forKey: KEY_DEFAULT_COMPANY)
        UserDefaults.standard.synchronize()
    }
    
    class func getSavedDefaultCompany() -> String? {
        return UserDefaults.standard.string(forKey: KEY_DEFAULT_COMPANY)
    }
}

// MARK:- Saving: Branding

extension AppSettings {
    private static let KEY_BRANDING_PRESET = "ASAPP_DEMO_KEY_BRANDING_PRESET"
    
    class func saveBranding(_ branding: Branding) {
        UserDefaults.standard.set(branding.brandingType.rawValue, forKey: KEY_BRANDING_PRESET)
        UserDefaults.standard.synchronize()
    }
    
    class func getSavedBranding() -> Branding? {
        if let rawValue = UserDefaults.standard.string(forKey: KEY_BRANDING_PRESET),
            let brandingType = BrandingType(rawValue: rawValue) {
            return Branding(brandingType: brandingType)
        }
        return nil
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
