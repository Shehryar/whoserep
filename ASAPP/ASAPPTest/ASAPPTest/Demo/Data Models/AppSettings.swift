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
}

class AppSettings: NSObject {

    let company: Company
    
    let companyMarker: String
    
    let styles: ASAPPStyles
    
    // MARK: Images
    
    var logoImage: UIImage?
    
    var logoImageSize: CGSize = CGSize(width: 140, height: 28)
    
    var homeBackgroundImage: UIImage?
    
    // MARK: Fonts
    
    // MARK: Colors
    
    var backgroundColor: UIColor = UIColor.white
    
    var backgroundColor2: UIColor = UIColor(red:0.941, green:0.937, blue:0.949, alpha:1)
    
    var foregroundColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.263, alpha:1)
    
    var foregroundColor2: UIColor = UIColor(red:0.483, green:0.505, blue:0.572, alpha:1)
    
    var separatorColor: UIColor = UIColor(red:0.644, green:0.662, blue:0.717, alpha:1)
    
    var navBarColor: UIColor = UIColor.white
    
    var navBarTintColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.265, alpha:1)
    
    var navBarTitleColor: UIColor = UIColor(red:0.220, green:0.231, blue:0.263, alpha:1)
    
    var statusBarStyle: UIStatusBarStyle = .default
    
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
            settings.navBarColor = UIColor.black //UIColor(red:0.220, green:0.231, blue:0.263, alpha:1)
            settings.navBarTintColor = UIColor.white
            settings.navBarTitleColor = UIColor.white
            settings.statusBarStyle = .lightContent
            return settings
            
        case .comcast:
            let settings = AppSettings(company: .comcast, companyMarker: "comcast", styles: ASAPP.stylesForCompany(company.rawValue))
            settings.logoImage = UIImage(named: "comcast-logo")
            settings.logoImageSize = CGSize(width: 140, height: 28)
            settings.homeBackgroundImage = UIImage(named: "comcast-home")
            
            settings.navBarColor = UIColor(red:0.074, green:0.075, blue:0.074, alpha:1)
            settings.navBarTintColor = UIColor.white
            settings.navBarTitleColor = UIColor.white
            settings.statusBarStyle = .lightContent
            
            return settings
            
        case .sprint:
            let settings = AppSettings(company: .sprint, companyMarker: "sprint", styles: ASAPP.stylesForCompany(company.rawValue))
            settings.logoImage = UIImage(named: "sprint-logo")
            settings.logoImageSize = CGSize(width: 140, height: 36)
            settings.homeBackgroundImage = UIImage(named: "sprint-home")
            
            settings.navBarTintColor = UIColor.darkGray
            settings.navBarTitleColor = UIColor.black
            
            return settings
        }
    }
    
    class func changeCompany(fromCompany company: Company) -> Company {
        let allCompanies: [Company] = [.asapp, .asapp2, .comcast, .sprint]
        
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
    
    private func userTokenStorageKey() -> String {
        return "\(company)-Demo-User-Token"
    }
    
    func getUserToken() -> String {
        if DemoSettings.useDemoPhoneUser() {
            return "+13126089137"
        }
        
        return UserDefaults.standard.string(forKey: userTokenStorageKey())
            ?? createNewUserToken()
    }
    
    func createNewUserToken() -> String {
        let freshUserToken = "\(company)-Test-Account-\(floor(Date().timeIntervalSince1970))"
        
        UserDefaults.standard.set(freshUserToken, forKey: userTokenStorageKey())
        
        return freshUserToken
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
