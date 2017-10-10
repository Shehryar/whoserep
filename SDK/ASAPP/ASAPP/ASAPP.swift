//
//  ASAPP.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

// MARK:- ASAPP

@objcMembers
public class ASAPP: NSObject {
    
    private(set) public static var config: ASAPPConfig!
    
    public static var user: ASAPPUser!
    
    public static var styles: ASAPPStyles = ASAPPStyles()
    
    public static var strings: ASAPPStrings = ASAPPStrings()
    
    public static var views: ASAPPViews = ASAPPViews()
    
    public static var debugLogLevel: ASAPPLogLevel = .errors
    
    // MARK:- Initialization
    
    public class func initialize(with config: ASAPPConfig) {
        ASAPP.config = config
        ASAPP.loadFonts()
    }
}

// MARK:- Entering Chat

public typealias ASAPPAppCallbackHandler = ((_ deepLink: String, _ deepLinkData: [String : Any]?) -> Void)

public extension ASAPP {
    public class func createChatViewControllerForPushing(fromNotificationWith userInfo: [AnyHashable : Any]?, appCallbackHandler: @escaping ASAPPAppCallbackHandler) -> UIViewController {
        assertSetupComplete()
        
        let chat = createBareChatViewController(fromNotificationWith: userInfo, segue: .push, appCallbackHandler: appCallbackHandler)
        let container = ContainerViewController(rootViewController: chat)
        
        return container
    }
    
    public class func createChatViewControllerForPresenting(fromNotificationWith userInfo: [AnyHashable : Any]?, appCallbackHandler: @escaping ASAPPAppCallbackHandler) -> UIViewController {
        assertSetupComplete()
        
        let chat = createBareChatViewController(fromNotificationWith: userInfo, appCallbackHandler: appCallbackHandler)
        let nav = NavigationController(rootViewController: chat)
        
        return nav
    }
    
    internal class func createBareChatViewController(fromNotificationWith userInfo: [AnyHashable : Any]?, segue: ASAPPSegue = .present, appCallbackHandler: @escaping ASAPPAppCallbackHandler) -> UIViewController {
        let chatViewController = ChatViewController(
            config: config,
            user: user,
            segue: segue,
            appCallbackHandler: appCallbackHandler)
        
        if canHandleNotification(with: userInfo) {
            chatViewController.showPredictiveOnViewAppear = false
        }
        
        return chatViewController
    }
    
    // deprecated in 3.0.0
    public class func createChatViewController(fromNotificationWith userInfo: [AnyHashable : Any]?, appCallbackHandler: @escaping ASAPPAppCallbackHandler) -> UIViewController {
        let chatViewController = ChatViewController(
            config: config,
            user: user,
            segue: .present,
            appCallbackHandler: appCallbackHandler)
        
        if canHandleNotification(with: userInfo) {
            chatViewController.showPredictiveOnViewAppear = false
        }
        
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
    
    public class func canHandleNotification(with userInfo: [AnyHashable : Any]?) -> Bool {
        guard let aps = userInfo?["aps"] as? [AnyHashable: Any] ?? userInfo else {
            return false
        }
        if let boolValue = aps["asapp"] as? Bool {
            return boolValue
        }
        return aps.keys.contains("asapp")
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
        FontLoader.load(bundle: ASAPP.bundle)
    }
}
