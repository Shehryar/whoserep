//
//  ASAPP.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

internal var DISTRIBUTION_BUILD = false

internal var DEMO_CONTENT_ENABLED = false
internal var DEMO_LIVE_CHAT = false
internal var DEMO_COMCAST_LIVE_CHAT_USER = false

// MARK:- Internal Constants

internal let ASAPPBundle = Bundle(for: ASAPP.self)

// MARK:- ASAPP Object

public class ASAPP: NSObject {
    
    // MARK: Constats
    
    public static let AUTH_KEY_ACCESS_TOKEN = "access_token"
    public static let AUTH_KEY_ISSUED_TIME = "issued_time"
    public static let AUTH_KEY_EXPIRES_IN = "expires_in"
    public static let CONTEXT_KEY_CUST_GUID = "custGUID"
    
    // MARK: Fonts
    
    static var didLoadFonts = false
    
    class func loadFontsIfNecessary() {
        if !didLoadFonts {
            Fonts.loadAllFonts()
            didLoadFonts = true
        }
    }
    
    class func loadedFonts() -> [String] {
        return Fonts.loadedFonts()
    }
    
    // MARK:- Chat Button
    
    /// Returns a new buttonView that can be manually added to a view.
    public class func createChatButton(company: String,
                                       customerId: String,
                                       environment: ASAPPEnvironment,
                                       authProvider: @escaping ASAPPAuthProvider,
                                       contextProvider: @escaping ASAPPContextProvider,
                                       callbackHandler: @escaping ASAPPCallbackHandler,
                                       styles: ASAPPStyles?,
                                       strings: ASAPPStrings?,
                                       presentingViewController: UIViewController) -> ASAPPButton {
        
        loadFontsIfNecessary()
        updateDemoSettings(withEnvironment: environment)
        
        let credentials = Credentials(withCompany: company,
                                      userToken: customerId,
                                      isCustomer: true,
                                      targetCustomerToken: nil,
                                      environment: environment,
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
                                customerId: customerId,
                                environment: environment,
                                authProvider: authProvider,
                                contextProvider: contextProvider,
                                callbackHandler: callbackHandler,
                                styles: styles,
                                strings: nil,
                                presentingViewController: presentingViewController)
    }
    
    // MARK:- Chat View Controller
    
    /// Returns a UINavigationController containing a new instance of the chat view controller.
    public class func createChatViewController(company: String,
                                               customerId: String,
                                               environment: ASAPPEnvironment,
                                               authProvider: @escaping ASAPPAuthProvider,
                                               contextProvider: @escaping ASAPPContextProvider,
                                               callbackHandler: @escaping ASAPPCallbackHandler,
                                               styles: ASAPPStyles?,
                                               strings: ASAPPStrings?) -> UIViewController {
        
        loadFontsIfNecessary()
        updateDemoSettings(withEnvironment: environment)
        
        let credentials = Credentials(withCompany: company,
                                      userToken: customerId,
                                      isCustomer: true,
                                      targetCustomerToken: nil,
                                      environment: environment,
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
                                        customerId: customerId,
                                        environment: environment,
                                        authProvider: authProvider,
                                        contextProvider: contextProvider,
                                        callbackHandler: callbackHandler,
                                        styles: styles,
                                        strings: nil)
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
    
    fileprivate class func updateDemoSettings(withEnvironment environment: ASAPPEnvironment) {
        guard !DISTRIBUTION_BUILD
            else {
                DebugLog("All demo settings disabled for distribution build")
                DEMO_CONTENT_ENABLED = false
                DEMO_LIVE_CHAT = false
                DEMO_COMCAST_LIVE_CHAT_USER = false
                return
        }
    
        DEMO_CONTENT_ENABLED = UserDefaults.standard.bool(forKey: "ASAPP_DEMO_CONTENT_ENABLED")
        DEMO_LIVE_CHAT = UserDefaults.standard.bool(forKey: "ASAPP_DEMO_LIVE_CHAT")
        DEMO_COMCAST_LIVE_CHAT_USER = UserDefaults.standard.bool(forKey: "ASAPP_DEMO_FORCE_PHONE_USER")
        
        DebugLog("\n\n==========\nUPDATING DEMO SETTINGS:\nDemo Content = \(DEMO_CONTENT_ENABLED)\nLive Chat = \(DEMO_LIVE_CHAT)\nPhone User = \(DEMO_COMCAST_LIVE_CHAT_USER)\n==========")
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
