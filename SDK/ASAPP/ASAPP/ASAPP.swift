//
//  ASAPP.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

public class ASAPP: NSObject {
    
    public static var config: ASAPPConfig!
    
    public static var styles: ASAPPStyles = ASAPPStyles()
    
    public static var strings: ASAPPStrings = ASAPPStrings()
    
    public static var debugLogLevel: ASAPPLogLevel = .errors
    
    // MARK: Internal Variables
    
    internal static let bundle = Bundle(for: ASAPP.self)
    
    internal static let soundEffectPlayer = SoundEffectPlayer()
    
    // MARK: Initialization
    
    public class func initialize(with config: ASAPPConfig) {
        ASAPP.config = config
        
        Fonts.loadFontsIfNecessary()
    }
}

public extension ASAPP {
    
    class func loadFonts() {
        Fonts.loadFontsIfNecessary()
    }
    
    internal class func assertSetupComplete() {
        assert(config != nil, "ASAPP.config must be set before calling this method.  You can call +initialize(with:) or set the static config property directly.")
        
        loadFonts()
    }

    public class func createChatViewController(appCallbackHandler: @escaping ASAPPAppCallbackHandler) -> UIViewController {
        assertSetupComplete()
        
        let chatViewController = ChatViewController(config: ASAPP.config, appCallbackHandler: appCallbackHandler)

        return NavigationController(rootViewController: chatViewController)
    }
    
    public class func createChatButton(appCallbackHandler: @escaping ASAPPAppCallbackHandler,
                                       presentingViewController: UIViewController) -> ASAPPButton {
        assertSetupComplete()
        
        return ASAPPButton(config: config,
                           appCallbackHandler: appCallbackHandler,
                           presentingViewController: presentingViewController)
    }
}
