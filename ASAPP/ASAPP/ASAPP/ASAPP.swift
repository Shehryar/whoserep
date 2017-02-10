//
//  ASAPP.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

internal var DISTRIBUTION_BUILD = false

internal var DEMO_LIVE_CHAT = true
internal var DEMO_CONTENT_ENABLED = false


// MARK- Enums & Typealiases

@objc public enum ASAPPEnvironment: Int {
    case staging
    case production
}

public func ASAPPSubdomainFrom(company: String, environment: ASAPPEnvironment) -> String {
    switch environment {
    case .staging: return "\(company).preprod"
    case .production: return "\(company)"
    }
}

public typealias ASAPPCallbackHandler = ((_ deepLink: String, _ deepLinkData: [String : Any]?) -> Void)

public typealias ASAPPContextProvider = (() -> [String : Any])

public typealias ASAPPAuthProvider = (() -> [String : Any])


// MARK:- Internal Constants

internal let ASAPPBundle = Bundle(for: ASAPP.self)

// MARK:- ASAPP Object

public class ASAPP: NSObject {
    
    // MARK: Constats
    
    public static let AUTH_KEY_ACCESS_TOKEN = "access_token"
    public static let AUTH_KEY_ISSUED_TIME = "issued_time"
    public static let AUTH_KEY_EXPIRES_IN = "expires_in"
    
    // MARK: Fonts + Setup
    
    static var didLoadFonts = false
    
    public class func loadFontsIfNecessary() {
        if !didLoadFonts {
            Fonts.loadAllFonts()
            didLoadFonts = true
        }
    }
    
    class func loadedFonts() -> [String] {
        return Fonts.loadedFonts()
    }
    
    private class func commontSetup(testMode: Bool) {
        loadFontsIfNecessary()
        if !DISTRIBUTION_BUILD {
            DEMO_CONTENT_ENABLED = testMode
        } else {
            DEMO_CONTENT_ENABLED = false
        }
    }
    
    // MARK:- Chat Button
    
    /// Returns a new buttonView that can be manually added to a view.
    public class func createChatButton(company: String,
                                       subdomain: String,
                                       customerId: String,
                                       authProvider: @escaping ASAPPAuthProvider,
                                       contextProvider: @escaping ASAPPContextProvider,
                                       callbackHandler: @escaping ASAPPCallbackHandler,
                                       styles: ASAPPStyles?,
                                       strings: ASAPPStrings?,
                                       testMode: Bool,
                                       presentingViewController: UIViewController) -> ASAPPButton {
        
        commontSetup(testMode: testMode)
        
        let credentials = Credentials(withCompany: company,
                                      subdomain: subdomain,
                                      userToken: customerId,
                                      isCustomer: true,
                                      targetCustomerToken: nil,
                                      authProvider: authProvider,
                                      contextProvider: contextProvider,
                                      callbackHandler: callbackHandler)
        
        return ASAPPButton(withCredentials: credentials,
                           presentingViewController: presentingViewController,
                           styles: styles ?? ASAPPStyles.stylesForCompany(company) ?? ASAPPStyles(),
                           strings: strings ?? ASAPPStrings(),
                           callback: callbackHandler)
    }
    
    public class func createChatButton(company: String,
                                       customerId: String,
                                       environment: ASAPPEnvironment,
                                       authProvider: @escaping ASAPPAuthProvider,
                                       contextProvider: @escaping ASAPPContextProvider,
                                       callbackHandler: @escaping ASAPPCallbackHandler,
                                       styles: ASAPPStyles?,
                                       presentingViewController: UIViewController) -> ASAPPButton {

        return createChatButton(company: company,
                                subdomain: ASAPPSubdomainFrom(company: company, environment: environment),
                                customerId: customerId,
                                authProvider: authProvider,
                                contextProvider: contextProvider,
                                callbackHandler: callbackHandler,
                                styles: styles,
                                strings: nil,
                                testMode: false,
                                presentingViewController: presentingViewController)
    }
    
    // MARK:- Chat View Controller
    
    /// Returns a UINavigationController containing a new instance of the chat view controller.
    public class func createChatViewController(company: String,
                                               subdomain: String,
                                               customerId: String,
                                               authProvider: @escaping ASAPPAuthProvider,
                                               contextProvider: @escaping ASAPPContextProvider,
                                               callbackHandler: @escaping ASAPPCallbackHandler,
                                               styles: ASAPPStyles?,
                                               strings: ASAPPStrings?,
                                               testMode: Bool) -> UIViewController {
        
        commontSetup(testMode: testMode)
        
        let credentials = Credentials(withCompany: company,
                                      subdomain: subdomain,
                                      userToken: customerId,
                                      isCustomer: true,
                                      targetCustomerToken: nil,
                                      authProvider: authProvider,
                                      contextProvider: contextProvider,
                                      callbackHandler: callbackHandler)
        
        let chatViewController = ChatViewController(withCredentials: credentials,
                                                    styles: styles ?? ASAPPStyles.stylesForCompany(company),
                                                    strings: strings ?? ASAPPStrings(),
                                                    callback: callbackHandler)
        
        return NavigationController(rootViewController: chatViewController)
    }
    
    public class func createChatViewController(company: String,
                                               customerId: String,
                                               environment: ASAPPEnvironment,
                                               authProvider: @escaping ASAPPAuthProvider,
                                               contextProvider: @escaping ASAPPContextProvider,
                                               callbackHandler: @escaping ASAPPCallbackHandler,
                                               styles: ASAPPStyles?) -> UIViewController {
        
        return createChatViewController(company: company,
                                        subdomain: ASAPPSubdomainFrom(company: company, environment: environment),
                                        customerId: customerId,
                                        authProvider: authProvider,
                                        contextProvider: contextProvider,
                                        callbackHandler: callbackHandler,
                                        styles: styles,
                                        strings: nil,
                                        testMode: false)
    }
    
    // MARK:
    
    public class func newStrings() -> ASAPPStrings {
        return ASAPPStrings()
    }
    
    public class func newStyles() -> ASAPPStyles {
        return ASAPPStyles()
    }
    
    public class func stylesForCompany(_ company: String) -> ASAPPStyles {
        return ASAPPStyles.stylesForCompany(company) ?? ASAPPStyles()
    }
    
    // MARK: Private
    
    fileprivate class func updateDemoSettings() {
        guard !DISTRIBUTION_BUILD
            else {
                DebugLog("All demo settings disabled for distribution build")
                DEMO_CONTENT_ENABLED = false
                return
        }
        DEMO_CONTENT_ENABLED = UserDefaults.standard.bool(forKey: "ASAPP_DEMO_CONTENT_ENABLED")
        
        DebugLog("\n\n==========\nASAPP DEMO SETTINGS:\nDemo Content = \(DEMO_CONTENT_ENABLED)\nLive Chat = \(DEMO_LIVE_CHAT)n==========")
    }
}

//
// MARK:- Debug Logging
//

public enum ASAPPLogLevel: Int {
    case None = 0
    case Errors = 1
    case Debug = 3
}

internal var DEBUG_LOG_LEVEL = ASAPPLogLevel.Errors

public extension ASAPP {
    public class func setLogLevel(logLevel: ASAPPLogLevel) {
        DEBUG_LOG_LEVEL = logLevel
    }
}
