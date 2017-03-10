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
    case debug = 2
    case info = 3
}

public func ASAPPSubdomainFrom(company: String, environment: ASAPPEnvironment) -> String {
    switch environment {
    case .staging: return "\(company).preprod"
    case .production: return "\(company)"
    }
}

public let ASAPP_DEFAULT_API_HOST = "asapp.com"

public func ASAPPAPIHostNameFrom(company: String, environment: ASAPPEnvironment) -> String {
    let subdomain = ASAPPSubdomainFrom(company: company, environment: environment)
    return "\(subdomain).\(ASAPP_DEFAULT_API_HOST)"
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
        return "2.2.1"
    }
    
    /// This is used to style all ASAPP views. This should be set before creating any ASAPP views.
    public static var styles: ASAPPStyles = ASAPPStyles()
    
    /// This is used for all ASAPP views. This should be set before creating any ASAPP views.
    public static var strings: ASAPPStrings = ASAPPStrings()
    
    internal static let soundEffectPlayer = SoundEffectPlayer()
    
    // MARK: Fonts + Setup
        
    public class func loadFontsIfNecessary() {
        Fonts.loadFontsIfNecessary()
    }
    
    class func loadedFonts() -> [String] {
        return Fonts.loadedFonts()
    }
}

//
// MARK:- Public API: Chat View Controller
//

public extension ASAPP {
    
    // MARK: Private
    
    fileprivate class func createChatViewController(credentials: Credentials,
                                                    callbackHandler: @escaping ASAPPCallbackHandler) -> UIViewController {
        loadFontsIfNecessary()
        
        let chatViewController = ChatViewController(withCredentials: credentials,
                                                    callback: callbackHandler)
        
        return NavigationController(rootViewController: chatViewController)
    }
    
    // MARK: Public: Chat View Controller
    
    /**
     Returns a UINavigationController containing an ASAPP ChatViewController instance.
     */
    public class func createChatViewController(company: String,
                                               customerId: String,
                                               environment: ASAPPEnvironment,
                                               authProvider: @escaping ASAPPAuthProvider,
                                               contextProvider: @escaping ASAPPContextProvider,
                                               callbackHandler: @escaping ASAPPCallbackHandler) -> UIViewController {
        let credentials = Credentials(withCompany: company,
                                      apiHostName: ASAPPAPIHostNameFrom(company: company, environment: environment),
                                      userToken: customerId,
                                      authProvider: authProvider,
                                      contextProvider: contextProvider,
                                      callbackHandler: callbackHandler)
        
        return createChatViewController(credentials: credentials, callbackHandler: callbackHandler)
    }
    
    /**
     Returns a UINavigationController containing an ASAPP ChatViewController instance.
     */
    public class func createChatViewController(company: String,
                                               apiHostName: String,
                                               customerId: String,
                                               authProvider: @escaping ASAPPAuthProvider,
                                               contextProvider: @escaping ASAPPContextProvider,
                                               callbackHandler: @escaping ASAPPCallbackHandler) -> UIViewController {
        let credentials = Credentials(withCompany: company,
                                      apiHostName: apiHostName,
                                      userToken: customerId,
                                      authProvider: authProvider,
                                      contextProvider: contextProvider,
                                      callbackHandler: callbackHandler)
        
        return createChatViewController(credentials: credentials, callbackHandler: callbackHandler)
    }
    
    // MARK: Public: Chat Button
    
    /**
     Returns a button that will show an ASAPP ChatViewController when pressed.
     */
    public class func createChatButton(company: String,
                                       customerId: String,
                                       environment: ASAPPEnvironment,
                                       authProvider: @escaping ASAPPAuthProvider,
                                       contextProvider: @escaping ASAPPContextProvider,
                                       callbackHandler: @escaping ASAPPCallbackHandler,
                                       presentingViewController: UIViewController) -> ASAPPButton {
        
        let credentials = Credentials(withCompany: company,
                                      apiHostName: ASAPPAPIHostNameFrom(company: company, environment: environment),
                                      userToken: customerId,
                                      authProvider: authProvider,
                                      contextProvider: contextProvider,
                                      callbackHandler: callbackHandler)
        
        return ASAPPButton(withCredentials: credentials,
                           presentingViewController: presentingViewController,
                           callback: callbackHandler)
    }
    
    /**
     Returns a button that will show an ASAPP ChatViewController when pressed.
     */
    public class func createChatButton(company: String,
                                       apiHostName: String,
                                       customerId: String,
                                       authProvider: @escaping ASAPPAuthProvider,
                                       contextProvider: @escaping ASAPPContextProvider,
                                       callbackHandler: @escaping ASAPPCallbackHandler,
                                       presentingViewController: UIViewController) -> ASAPPButton {
        
        let credentials = Credentials(withCompany: company,
                                      apiHostName: apiHostName,
                                      userToken: customerId,
                                      authProvider: authProvider,
                                      contextProvider: contextProvider,
                                      callbackHandler: callbackHandler)
        
        return ASAPPButton(withCredentials: credentials,
                           presentingViewController: presentingViewController,
                           callback: callbackHandler)
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









// Remove after 2.2.0


//
// MARK:- Deprecated API
//

public extension ASAPP {
    
    // MARK:- Common Setup
    
    private class func performDeprecatedSetup(for company: String, styles: ASAPPStyles?, strings: ASAPPStrings?) {
        loadFontsIfNecessary()
        
        if let styles = styles {
            ASAPP.styles = styles
        } else {
            ASAPP.styles = ASAPPStyles.stylesForCompany(company)
        }
        if let strings = strings {
            ASAPP.strings = strings
        }
    }
    
    /**
     **This method is deprecated.** Returns a UINavigationController containing an ASAPP ChatViewController instance.
     */
    public class func createChatViewController(company: String,
                                               customerId: String,
                                               environment: ASAPPEnvironment,
                                               authProvider: @escaping ASAPPAuthProvider,
                                               contextProvider: @escaping ASAPPContextProvider,
                                               callbackHandler: @escaping ASAPPCallbackHandler,
                                               styles: ASAPPStyles?) -> UIViewController {
        
        performDeprecatedSetup(for: company, styles: styles, strings: strings)
        
        let credentials = Credentials(withCompany: company,
                                      apiHostName: ASAPPAPIHostNameFrom(company: company, environment: environment),
                                      userToken: customerId,
                                      authProvider: authProvider,
                                      contextProvider: contextProvider,
                                      callbackHandler: callbackHandler)
        
        return createChatViewController(credentials: credentials, callbackHandler: callbackHandler)
    }
    
    /**
     **This method is deprecated.** Returns a button that will show an ASAPP ChatViewController when pressed.
     */
    public class func createChatButton(company: String,
                                       customerId: String,
                                       environment: ASAPPEnvironment,
                                       authProvider: @escaping ASAPPAuthProvider,
                                       contextProvider: @escaping ASAPPContextProvider,
                                       callbackHandler: @escaping ASAPPCallbackHandler,
                                       styles: ASAPPStyles?,
                                       presentingViewController: UIViewController) -> ASAPPButton {
        
        performDeprecatedSetup(for: company, styles: styles, strings: strings)
        
        let credentials = Credentials(withCompany: company,
                                      apiHostName: ASAPPAPIHostNameFrom(company: company, environment: environment),
                                      userToken: customerId,
                                      authProvider: authProvider,
                                      contextProvider: contextProvider,
                                      callbackHandler: callbackHandler)
        
        return ASAPPButton(withCredentials: credentials,
                           presentingViewController: presentingViewController,
                           callback: callbackHandler)
    }
}
