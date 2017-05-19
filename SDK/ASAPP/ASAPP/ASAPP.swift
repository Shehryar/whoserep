//
//  ASAPP.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

// MARK:- ASAPP

public class ASAPP: NSObject {
    
    private(set) public static var config: ASAPPConfig!
    
    public static var user: ASAPPUser!
    
    public static var styles: ASAPPStyles = ASAPPStyles()
    
    public static var strings: ASAPPStrings = ASAPPStrings()
    
    public static var debugLogLevel: ASAPPLogLevel = .errors
    
    // MARK:- Initialization
    
    public class func initialize(with config: ASAPPConfig) {
        ASAPP.config = config
        
        Fonts.loadFontsIfNecessary()
    }
}

// MARK:- Entering Chat

public typealias ASAPPAppCallbackHandler = ((_ deepLink: String, _ deepLinkData: [String : Any]?) -> Void)

public extension ASAPP {

    public class func createChatViewController(appCallbackHandler: @escaping ASAPPAppCallbackHandler) -> UIViewController {
        assertSetupComplete()
        
        let chatViewController = ChatViewController(config: config,
                                                    user: user,
                                                    appCallbackHandler: appCallbackHandler)

        return NavigationController(rootViewController: chatViewController)
    }
    
    public class func createChatButton(appCallbackHandler: @escaping ASAPPAppCallbackHandler,
                                       presentingViewController: UIViewController) -> ASAPPButton {
        assertSetupComplete()
        
        return ASAPPButton(config: config,
                           user: user,
                           appCallbackHandler: appCallbackHandler,
                           presentingViewController: presentingViewController)
    }
}

// MARK:- Internal Utility

public extension ASAPP {
    
    internal static let bundle = Bundle(for: ASAPP.self)
    
    internal static let soundEffectPlayer = SoundEffectPlayer()
    
    internal class func assertSetupComplete() {
        assert(config != nil, "ASAPP.config must be set before calling this method. You can set the config by calling method +initialize(with:) from your app delegate.")
        
        
        assert(user != nil, "ASAPP.user must be set before calling this method.")
        
        loadFonts()
    }
    
    public class func loadFonts() {
        Fonts.loadFontsIfNecessary()
    }
}
