//
//  ASAPP.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

@objc public enum ASAPPEnvironment: Int {
    case staging
    case production
}

@objc public enum ASAPPLogLevel: Int {
    case none = 0
    case errors = 1
    case debug = 3
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

internal let ASAPPBundle = Bundle(for: ASAPP.self)

// MARK:- ASAPP Object

public class ASAPP: NSObject {
    
    // MARK: Public Constants
    
    public static let AUTH_KEY_ACCESS_TOKEN = "access_token"
    public static let AUTH_KEY_ISSUED_TIME = "issued_time"
    public static let AUTH_KEY_EXPIRES_IN = "expires_in"
    
    internal static let CLIENT_TYPE_KEY = "ASAPP-ClientType"
    internal static let CLIENT_TYPE_VALUE = "consumer-ios-sdk"
    internal static let CLIENT_VERSION_KEY = "ASAPP-ClientVersion"
    internal static let CLIENT_SECRET_KEY = "ASAPP-ClientSecret"
    
    public static var debugLogLevel: ASAPPLogLevel = .errors
    
    public static var clientVersion: String {
        if let bundleVersion = ASAPPBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return bundleVersion
        }
        return "2.2.0"
    }
    
    /// This is used to style all ASAPP views. This should be set before creating any ASAPP views.
    public static var styles: ASAPPStyles = ASAPPStyles()
    
    /// This is used for all ASAPP views. This should be set before creating any ASAPP views.
    public static var strings: ASAPPStrings = ASAPPStrings()
    
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
                                       presentingViewController: UIViewController) -> ASAPPButton {
        loadFontsIfNecessary()
        
        if let styles = styles {
            ASAPP.styles = styles
        }
        if let strings = strings {
            ASAPP.strings = strings
        }
        
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
                                               strings: ASAPPStrings?) -> UIViewController {
        
        loadFontsIfNecessary()
        
        if let styles = styles {
            ASAPP.styles = styles
        }
        if let strings = strings {
            ASAPP.strings = strings
        }
        
        let credentials = Credentials(withCompany: company,
                                      subdomain: subdomain,
                                      userToken: customerId,
                                      isCustomer: true,
                                      targetCustomerToken: nil,
                                      authProvider: authProvider,
                                      contextProvider: contextProvider,
                                      callbackHandler: callbackHandler)
        
        let chatViewController = ChatViewController(withCredentials: credentials,
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
                                        strings: nil)
    }
}

//
// MARK:- Internal-Use Only
//

public extension ASAPP {
    
    internal static var isInternalBuild: Bool {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            return bundleIdentifier.contains("com.asappinc.")
        }
        return false
    }
    
    // MARK: Demo Content
    
    private static var demoContentEnabled = false
    
    public class func isDemoContentEnabled() -> Bool {
        if isInternalBuild {
            return demoContentEnabled
        } else {
            return false
        }
    }
    
    public class func setDemoContentEnabled(_ enabled: Bool) {
        if isInternalBuild {
            demoContentEnabled = enabled
            DebugLog("Demo Content: \(enabled)")
        } else {
            DebugLogError("Demo Content Disabled")
        }
    }
}
