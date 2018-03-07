//
//  ASAPP.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

/// A `Void` closure type that takes a deep link's name as a `String` and the deep link's metadata as a `[String: Any]?`.
public typealias ASAPPAppCallbackHandler = ((_ deepLink: String, _ deepLinkData: [String: Any]?) -> Void)

/// A protocol defining functions that can be called by the framework.
@objc public protocol ASAPPDelegate {
    /// Called when a user taps a login button. Please set `ASAPP.user` once the user has logged in.
    func chatViewControllerDidTapUserLoginButton()
}

/**
 The `ASAPP` class holds references to its various configurable properties and allows you
 to call various functions. No instances of `ASAPP` are to be created.
 */
@objc(ASAPP)
@objcMembers
public class ASAPP: NSObject {
    
    /// The key for referencing an auth token in a request context dictionary.
    public static let authTokenKey = "access_token"
    
    /**
     The SDK version.
     
     - returns: A `String` representing the SDK version in x.y.z format.
     */
    public static var clientVersion: String {
        if let bundleVersion = ASAPP.bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return bundleVersion
        }
        return "3.0.0"
    }
    
    // MARK: - Properties
    
    /// The delegate, currently only used for handling logging in.
    public static weak var delegate: ASAPPDelegate?
    
    /// Set by calling `ASAPP.initialize(with:)`, typically in the `AppDelegate`.
    private(set) public static var config: ASAPPConfig!
    
    /// The current user.
    public static var user: ASAPPUser! {
        didSet {
            NotificationCenter.default.post(name: .UserDidChange, object: nil)
        }
    }
    
    /// The SDK can be styled to fit your brand.
    public static var styles: ASAPPStyles = ASAPPStyles()
    
    /// Strings displayed by the SDK can be customized.
    public static var strings: ASAPPStrings = ASAPPStrings()
    
    /// Certain views displayed by the SDK can be customized.
    public static var views: ASAPPViews = ASAPPViews()
    
    /// Verbosity of the debugging log. Defaults to `.errors`.
    public static var debugLogLevel: ASAPPLogLevel = .errors
    
    // MARK: - Initialization
    
    /**
     Sets the `config` property and loads built-in fonts, if necessary.
     
     - parameter config: An `ASAPPConfig` instance used to configure the SDK.
     */
    public class func initialize(with config: ASAPPConfig) {
        ASAPP.config = config
        ASAPP.loadFonts()
    }

    // MARK: - Entering Chat
    
    /**
     Creates a chat view controller, ready to be pushed onto a navigation stack.
     
     - returns: A `UIViewController`
     - parameter userInfo: A user info dictionary containing notification metadata
     - parameter appCallbackHandler: An `ASAPPCallbackHandler`
     */
    public class func createChatViewControllerForPushing(fromNotificationWith userInfo: [AnyHashable: Any]?, appCallbackHandler: @escaping ASAPPAppCallbackHandler) -> UIViewController {
        assertSetupComplete()
        
        let chat = createBareChatViewController(fromNotificationWith: userInfo, segue: .push, appCallbackHandler: appCallbackHandler)
        let container = ContainerViewController(rootViewController: chat)
        
        return container
    }
    
    /**
     Creates a chat view controller in a navigation controller, ready to be presented modally.
     
     - returns: A `UIViewController`
     - parameter userInfo: A user info dictionary containing notification metadata
     - parameter appCallbackHandler: An `ASAPPCallbackHandler`
     */
    public class func createChatViewControllerForPresenting(fromNotificationWith userInfo: [AnyHashable: Any]?, appCallbackHandler: @escaping ASAPPAppCallbackHandler) -> UIViewController {
        assertSetupComplete()
        
        let chat = createBareChatViewController(fromNotificationWith: userInfo, appCallbackHandler: appCallbackHandler)
        let nav = NavigationController(rootViewController: chat)
        
        return nav
    }
    
    /**
     Creates a button that will launch the SDK when tapped. Configure the segue style
     by setting the `ASAPPStyles.segue` property.
     
     - returns: An `ASAPPButton`
     - parameter appCallbackHandler: An `ASAPPCallbackHandler`
     - parameter presentingViewController: The `UIViewController` which will either present or push onto its navigation controller the SDK's view controller.
     */
    public class func createChatButton(appCallbackHandler: @escaping ASAPPAppCallbackHandler,
                                       presentingViewController: UIViewController) -> ASAPPButton {
        assertSetupComplete()
        
        return ASAPPButton(config: config,
                           user: user,
                           appCallbackHandler: appCallbackHandler,
                           presentingViewController: presentingViewController)
    }
    
    // MARK: - Push Notifications
    
    /**
     Whether the SDK should request notification authorization shortly after a user's first interaction,
     such as sending a message or pressing a button.
     */
    public static var shouldRequestNotificationAuthorization = false
    
    /**
     Called when the user denies notification authorization. iOS 10+. For iOS 9, please implement
     `application(_:didRegister:)` in your `UIApplicationDelegate`.
     */
    @available(iOS 10.0, *)
    public static var notificationAuthorizationDenied: (() -> Void)?
    
    /**
     Enables ASAPP push notifications for this device.
     
     - parameter deviceToken: The token provided by APNS in `didRegisterForRemoteNotificationsWithDeviceToken(_:)`
     */
    public class func enablePushNotifications(with deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        PushNotificationsManager.shared.deviceToken = token
        PushNotificationsManager.shared.enableIfSessionExists()
    }
    
    /// A `Void` closure type that takes an `Int`, the number of unread messages.
    public typealias UnreadMessagesHandler = ((_ unread: Int) -> Void)
    
    /**
     Gets the number of messages the user received while offline.
     
     - parameter handler: An `UnreadNumberHandler` that receives the number of unread ASAPP push notifications.
     */
    public class func getNumberOfUnreadMessages(_ handler: @escaping UnreadMessagesHandler) {
        return PushNotificationsManager.shared.getUnreadMessagesCount(handler)
    }
    
    /**
     Should be called to detect an ASAPP notification before calling
     `createChatViewControllerForPresenting(fromNotificationWith:appCallbackHandler:)`.
     
     - returns: Whether the SDK can handle a notification.
     - parameter userInfo: A user info dictionary containing notification metadata
     */
    public class func canHandleNotification(with userInfo: [AnyHashable: Any]?) -> Bool {
        guard let aps = userInfo?["aps"] as? [AnyHashable: Any] ?? userInfo else {
            return false
        }
        if let boolValue = aps["asapp"] as? Bool {
            return boolValue
        }
        return aps.keys.contains("asapp")
    }
    
    // MARK: - Session Management
    
    /// Clears the session saved on disk.
    public class func clearSavedSession() {
        SavedSessionManager.shared.clearSession()
    }
    
    // MARK: - Fonts
    
    /// Loads the SDK's built-in fonts.
    public class func loadFonts() {
        FontLoader.load(bundle: ASAPP.bundle)
    }
}

internal extension ASAPP {
    // MARK: - Internal Utility
    
    static var userLoginAction: UserLoginAction?
    
    static let bundle = Bundle(for: ASAPP.self)
    
    static let soundEffectPlayer = SoundEffectPlayer()
    
    class func assertSetupComplete() {
        assert(config != nil, "ASAPP.config must be set before calling this method. You can set the config by calling method +initialize(with:) from your app delegate.")
        
        assert(user != nil, "ASAPP.user must be set before calling this method.")
        
        loadFonts()
    }
    
    class func createBareChatViewController(fromNotificationWith userInfo: [AnyHashable: Any]?, segue: ASAPPSegue = .present, appCallbackHandler: @escaping ASAPPAppCallbackHandler) -> UIViewController {
        let chatViewController = ChatViewController(
            config: config,
            user: user,
            segue: segue,
            appCallbackHandler: appCallbackHandler)
        
        return chatViewController
    }
}
