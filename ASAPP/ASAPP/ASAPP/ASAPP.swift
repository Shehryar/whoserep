//
//  ASAPP.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

// MARK:- Internal Constants

internal let ASAPPBundle = Bundle(for: ASAPP.self)

internal let DEMO_CONTENT_ENABLED = false


// MARK:- ASAPP Object

public class ASAPP: NSObject {
    
    // MARK: Constats
    
    public static let AUTH_KEY_ACCESS_TOKEN = "access_token"
    public static let AUTH_KEY_ISSUED_TIME = "issued_time"
    public static let AUTH_KEY_EXPIRES_IN = "expires_in"
    public static let CONTEXT_KEY_CUST_GUID = "custGUID"
    
    // MARK: Fonts
    
    override public class func initialize() {
        Fonts.loadAllFonts()
    }
    
    class func loadFonts() {
        Fonts.loadAllFonts()
    }
    
    class func loadedFonts() -> [String] {
        return Fonts.loadedFonts()
    }
    
    /// Returns a new buttonView that can be manually added to a view.
    
    public class func createChatButton(company: String,
                                       customerId: String,
                                       environment: ASAPPEnvironment,
                                       authProvider: @escaping ASAPPAuthProvider,
                                       contextProvider: @escaping ASAPPContextProvider,
                                       callbackHandler: @escaping ASAPPCallbackHandler,
                                       styles: ASAPPStyles?,
                                       presentingViewController: UIViewController) -> ASAPPButton {
        
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
                           styles: styles ?? ASAPPStyles.comcastStyles(),
                           callback: callbackHandler)
    }
    
    /// Returns a UINavigationController containing a new instance of the chat view controller.
    
    public class func createChatViewController(company: String,
                                               customerId: String,
                                               environment: ASAPPEnvironment,
                                               authProvider: @escaping ASAPPAuthProvider,
                                               contextProvider: @escaping ASAPPContextProvider,
                                               callbackHandler: @escaping ASAPPCallbackHandler,
                                               styles: ASAPPStyles?) -> UIViewController {
        
        let credentials = Credentials(withCompany: company,
                                      userToken: customerId,
                                      isCustomer: true,
                                      targetCustomerToken: nil,
                                      environment: environment,
                                      authProvider: authProvider,
                                      contextProvider: contextProvider,
                                      callbackHandler: callbackHandler)
        
        let chatViewController = ChatViewController(withCredentials: credentials,
                                                    styles: styles ?? ASAPPStyles.comcastStyles(),
                                                    callback: callbackHandler)
        
        return NavigationController(rootViewController: chatViewController)
    }
}

// MARK:- Debug Logging

public enum ASAPPLogLevel: Int {
    case None = 0
    case Errors = 1
    case Debug = 3
}

internal var DEBUG_LOG_LEVEL = ASAPPLogLevel.None

public extension ASAPP {
    public class func setLogLevel(logLevel: ASAPPLogLevel) {
        DEBUG_LOG_LEVEL = logLevel
    }
}


/***  Remove this code after successul integration
 
// MARK:- Deprecated API

public class SRS: NSObject {
    
    public var button: ASAPPButton!
    
    // MARK: Initialization
    
    required public init(withOrigin origin: CGPoint,
                         authProvider: @escaping ASAPPAuthProvider,
                         contextProvider: @escaping ASAPPContextProvider,
                         callback: @escaping ASAPPCallbackHandler,
                         presentingViewController: UIViewController,
                         environment: ASAPPEnvironment) {
        super.init()
        
        let context = contextProvider()
        guard let userToken = context[ASAPP.CONTEXT_KEY_CUST_GUID] as? String else {
            fatalError("Missing parameter \"\(ASAPP.CONTEXT_KEY_CUST_GUID)\" in contextProvider response:\n\(context)\n\nTo resolve this error, you must provide the \"\(ASAPP.CONTEXT_KEY_CUST_GUID)\" (String) to identify your user.\n\nAlternatively, you could use the updated ASAPP object interface to create your ASAPP-powered chat.")
        }
        
        let creds = Credentials(withCompany: "comcast",
                                userToken: userToken,
                                isCustomer: true,
                                targetCustomerToken: nil,
                                environment: environment,
                                authProvider: authProvider,
                                contextProvider: contextProvider,
                                callbackHandler: callback)
        
        button = ASAPPButton(withCredentials: creds,
                             presentingViewController: presentingViewController,
                             styles: ASAPPStyles.comcastStyles(),
                             callback: callback)
        button.frame.origin = origin
        
        UIApplication.shared.keyWindow?.addSubview(button)
    }
    
    convenience public init(withOrigin origin: CGPoint,
                            authProvider: @escaping (() -> [String : Any]),
                            contextProvider: @escaping ASAPPContextProvider,
                            callback: @escaping ASAPPCallbackHandler) {
        
        guard let presentingViewController = UIApplication.shared.keyWindow?.rootViewController else {
            fatalError("Unable to find the keyWindow's rootViewController. Please make sure you are calling this method after setting the keyWindow and its rootViewController. Alternatively, you can use the init method that allows you to specify a specific viewController as the presentingViewController.  Even better yet, you could use the ASAPP object interface to use the most up-to-date API.")
        }
        
        self.init(withOrigin: origin,
                  authProvider: authProvider,
                  contextProvider: contextProvider,
                  callback: callback,
                  presentingViewController: presentingViewController,
                  environment: .production)
    }
    
    // MARK: Instance Methods / Convenience Things
    
    public var isHidden: Bool {
        set { button.isHidden = newValue }
        get { return button.isHidden }
    }
}

 ***/

