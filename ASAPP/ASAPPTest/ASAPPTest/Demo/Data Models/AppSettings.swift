//
//  AppSettings.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

enum Company: String {
    case asapp = "asapp"
    case asapp2 = "asapp2"
    case comcast = "comcast"
    case sprint = "sprint"
    
    static let all = [
        asapp,
        asapp2,
        comcast,
        sprint
    ]
}

class AppSettings: NSObject {
    
    let company: Company
    
    let companyMarker: String
    
    let styles: ASAPPStyles
    
    // MARK: Images
    
    var logoImage: UIImage?
    
    var logoImageSize: CGSize = CGSize(width: 140, height: 28)
    
    var homeBackgroundImage: UIImage?
    
    // MARK: Colors
    
    var backgroundColor: UIColor = UIColor.white
    
    var backgroundColor2: UIColor = UIColor(red:0.941, green:0.937, blue:0.949, alpha:1)
    
    var foregroundColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.263, alpha:1)
    
    var foregroundColor2: UIColor = UIColor(red:0.483, green:0.505, blue:0.572, alpha:1)
    
    var separatorColor: UIColor = UIColor(red:0.874, green:0.875, blue:0.874, alpha:1)
    
    var navBarColor: UIColor = UIColor.white
    
    var navBarTintColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.265, alpha:1)
    
    var navBarTitleColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.263, alpha:1)
    
    var statusBarStyle: UIStatusBarStyle = .default
    
    // MARK: Fonts
    
    var lightFont: UIFont = DemoFonts.latoLightFont(withSize: 14)
    
    var regularFont: UIFont = DemoFonts.latoRegularFont(withSize: 14)
    
    var boldFont: UIFont = DemoFonts.latoBoldFont(withSize: 14)
    
    var blackFont: UIFont = DemoFonts.latoBlackFont(withSize: 14)
    
    // MARK: Init
    
    init(company: Company, companyMarker: String, styles: ASAPPStyles?) {
        self.company = company
        self.companyMarker = companyMarker
        self.styles = styles ?? ASAPPStyles()
        super.init()
    }
}

// MARK:- Presets

extension AppSettings {
    
    class func settingsFor(_ company: Company) -> AppSettings {
        
        switch company {
        case .asapp:
            let settings = AppSettings(company: .asapp, companyMarker: "asapp", styles: ASAPPStyles())
            settings.logoImage = UIImage(named: "asapp-logo")
            settings.logoImageSize = CGSize(width: 100, height: 22)
            return settings
            
        case .asapp2:
            let settings = AppSettings(company: .asapp2, companyMarker: "asapp", styles: ASAPPStyles())
            settings.logoImage = UIImage(named: "asapp-logo-light")
            settings.logoImageSize = CGSize(width: 100, height: 22)
            
            settings.navBarColor = UIColor(red:0.01, green:0.01, blue:0.03, alpha:1)
            settings.navBarTintColor = UIColor.white
            settings.navBarTitleColor = UIColor.white
            settings.statusBarStyle = .lightContent
            
            //            settings.backgroundColor = UIColor(red:0.075, green:0.078, blue:0.078, alpha:1)
            //            settings.backgroundColor2 = UIColor(red:0.110, green:0.110, blue:0.122, alpha:1)
            //            settings.foregroundColor = UIColor.white
            //            settings.foregroundColor2 = UIColor(red:0.682, green:0.686, blue:0.703, alpha:1)
            //            settings.separatorColor = UIColor(red:0.259, green:0.259, blue:0.263, alpha:1)
            
            return settings
            
        case .comcast:
            let settings = AppSettings(company: .comcast, companyMarker: "comcast", styles: ASAPP.stylesForCompany(company.rawValue))
            settings.logoImage = UIImage(named: "comcast-logo")
            settings.logoImageSize = CGSize(width: 140, height: 28)
//            settings.homeBackgroundImage = UIImage(named: "comcast-home")
            
            
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
            
            // Fonts
            settings.lightFont = DemoFonts.xfinitySansLgtFont()
            settings.regularFont = DemoFonts.xfinitySansRegFont()
            settings.boldFont = DemoFonts.xfinitySansMedFont()
            settings.blackFont = DemoFonts.xfinitySansBoldFont()
            
            return settings
            
        case .sprint:
            let settings = AppSettings(company: .sprint, companyMarker: "sprint", styles: ASAPP.stylesForCompany(company.rawValue))
            settings.logoImage = UIImage(named: "sprint-logo")
            settings.logoImageSize = CGSize(width: 140, height: 36)
//            settings.homeBackgroundImage = UIImage(named: "sprint-home")
            
            // Nav Bar Colors
            settings.navBarTintColor = UIColor.darkGray
            settings.navBarTitleColor = UIColor.black
            
            // Colors
            settings.foregroundColor = UIColor(red:0, green:0, blue:0, alpha:1)
            settings.foregroundColor2 = UIColor(red:0.490, green:0.490, blue:0.490, alpha:1)
            settings.backgroundColor = UIColor.white
            settings.separatorColor = UIColor(red:0.882, green:0.882, blue:0.882, alpha:1)
            
            // Fonts
            settings.lightFont = DemoFonts.sprintSansRegularFont()
            settings.regularFont = DemoFonts.sprintSansRegularFont()
            settings.boldFont = DemoFonts.sprintSansMediumFont()
            settings.blackFont = DemoFonts.sprintSansBoldFont()
            
            return settings
        }
    }
    
    class func changeCompany(fromCompany company: Company) -> Company {
        let allCompanies = Company.all
        var nextCompany: Company = allCompanies[0]
        if let index = allCompanies.index(of: company) {
            if index + 1 >= allCompanies.count {
                nextCompany = allCompanies[0]
            } else {
                nextCompany = allCompanies[index + 1]
            }
        }
        return nextCompany
    }
}


// MARK:- User Token

extension AppSettings {
    
    private func accountStorageKey() -> String {
        return "\(company)-Demo-Account-Key"
    }
    
    private func userTokenStorageKey() -> String {
        return "\(company)-Demo-User-Token"
    }
    
    func getCurrentAccount() -> UserAccount {
        if let savedAccount = UserAccount.getSavedAccount(withKey: accountStorageKey()) {
            return savedAccount
        }
        
        let account = UserAccount.newRandomAccount()
        account.save(withKey: accountStorageKey())
        
        return account
    }
    
    func setCurrentAccount(account: UserAccount) {
        account.save(withKey: accountStorageKey())
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
            ASAPP.AUTH_KEY_ACCESS_TOKEN : "fake_access_token_abc12345",
            ASAPP.AUTH_KEY_ISSUED_TIME : Date(),
            ASAPP.AUTH_KEY_EXPIRES_IN : 60 * 60
        ]
    }
}
