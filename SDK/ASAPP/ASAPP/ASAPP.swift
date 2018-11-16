//
//  ASAPP.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

/// A protocol defining functions that can be called by the framework.
@objc public protocol ASAPPDelegate {
    /// Called when a user taps on a login button. Please set `ASAPP.user` once the user has logged in.
    func chatViewControllerDidTapUserLoginButton()
    
    /// Called when the ASAPP view controller has disappeared.
    func chatViewControllerDidDisappear()
    
    /// Called when a user taps on a deep link.
    func chatViewControlledDidTapDeepLink(name: String, data: [String: Any]?)
    
    /// Called when a user taps on a web link. Please return `true` if ASAPP should open the web link or `false` otherwise.
    func chatViewControllerShouldHandleWebLink(url: URL) -> Bool
}

/**
 The `ASAPP` class holds references to its various configurable properties and allows you
 to call various functions. No instances of `ASAPP` are to be created.
 */
@objc(ASAPP)
@objcMembers
public class ASAPP: NSObject {
    // MARK: - Constants
    
    /// The key for referencing the auth token in a request context dictionary.
    public static let authTokenKey = "access_token"
    
    /// The key for referencing the analytics dictionary in a request context dictionary.
    public static let analyticsKey = "partnerAnalytics"
    
    /// A `String` representing the SDK version in x.y.z format.
    public static var clientVersion: String {
        if let bundleVersion = ASAPP.bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return bundleVersion
        }
        return "3.0.0"
    }
    
    // MARK: - Properties
    
    /// The delegate, whose methods are called to allow you to respond to various events.
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
     Sets the `config` property.
     
     - parameter config: An `ASAPPConfig` instance used to configure the SDK.
     */
    public class func initialize(with config: ASAPPConfig) {
        ASAPP.config = config
        HTTPClient.shared.config(config)
    }

    // MARK: - Entering Chat
    
    /**
     Creates a chat view controller, ready to be pushed onto a navigation stack.
     
     - returns: A `UIViewController`
     - parameter userInfo: A user info dictionary containing notification metadata
     */
    public class func createChatViewControllerForPushing(fromNotificationWith userInfo: [AnyHashable: Any]?) -> UIViewController {
        assertSetupComplete()
        
        let chat = createBareChatViewController(fromNotificationWith: userInfo, segue: .push, supportedOrientations: styles.allowedOrientations)
        let container = ContainerViewController(rootViewController: chat)
        
        return container
    }
    
    /**
     Creates a chat view controller in a navigation controller, ready to be presented modally.
     
     - returns: A `UIViewController`
     - parameter userInfo: A user info dictionary containing notification metadata
     */
    public class func createChatViewControllerForPresenting(fromNotificationWith userInfo: [AnyHashable: Any]?) -> UIViewController {
        assertSetupComplete()
        
        let chat = createBareChatViewController(fromNotificationWith: userInfo, supportedOrientations: styles.allowedOrientations)
        let nav = NavigationController(rootViewController: chat)
        
        return nav
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
     Enables ASAPP push notifications for this device. The device token is saved in memory for later use when registering.
     
     - parameter deviceToken: The token provided by APNS in `didRegisterForRemoteNotificationsWithDeviceToken(_:)`
     */
    public class func enablePushNotifications(with deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        PushNotificationsManager.shared.deviceToken = token
        PushNotificationsManager.shared.enableIfSessionExists()
    }
    
    /**
     Enables ASAPP push notifications for this device. The UUID is saved in memory for later use when registering.
     
     - parameter uuid: An arbitrary string used by a separate push notification system to uniquely identify the device.
     */
    @objc(enablePushNotificationsWithUUID:)
    public class func enablePushNotifications(with uuid: String) {
        PushNotificationsManager.shared.deviceToken = uuid
        PushNotificationsManager.shared.enableIfSessionExists()
    }
    
    /// A `Void` closure type that takes an `Int`, the number of unread messages; and a `Bool`, whether the user is in a live chat.
    public typealias ChatStatusHandler = ((_ unread: Int, _ isLiveChat: Bool) -> Void)
    
    /**
     Gets the number of messages the user received while offline as well as whether user is currently in a live chat.
     
     - parameter handler: A `ChatStatusHandler` that receives the number of unread ASAPP push notifications and the live chat status.
     */
    public class func getChatStatus(_ handler: @escaping ChatStatusHandler) {
        return PushNotificationsManager.shared.getChatStatus(handler)
    }
    
    /**
     Should be called to detect an ASAPP notification before calling
     `createChatViewControllerForPresenting(fromNotificationWith:appCallbackHandler:)`.
     
     - returns: Whether the SDK can handle a notification.
     - parameter userInfo: A user info dictionary containing notification metadata
     */
    public class func canHandleNotification(with userInfo: [AnyHashable: Any]?) -> Bool {
        return userInfo?.keys.contains("FromASAPP") ?? false
    }
    
    // MARK: - Session Management
    
    /// Clears the session saved on disk.
    public class func clearSavedSession() {
        SavedSessionManager.shared.clearSession()
    }
}

internal extension ASAPP {
    // MARK: - Internal Utility
    
    static var userLoginAction: UserLoginAction?
    
    static let bundle = Bundle(for: ASAPP.self)
    
    static let soundEffectPlayer = SoundEffectPlayer()
    
    static var partnerAppVersion: String {
        if let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return bundleVersion
        }
        return ""
    }
    
    class func assertSetupComplete() {
        assert(config != nil, "ASAPP.config must be set before calling this method. You can set the config by calling method +initialize(with:) from your app delegate.")
        
        assert(user != nil, "ASAPP.user must be set before calling this method.")
    }
    
    class func createBareChatViewController(fromNotificationWith userInfo: [AnyHashable: Any]?, segue: Segue = .present, supportedOrientations: ASAPPAllowedOrientations) -> UIViewController {
        let conversationManager = ConversationManager(config: config, user: user, userLoginAction: nil)
        let chatViewController = ChatViewController(
            config: config,
            user: user,
            segue: segue,
            conversationManager: conversationManager,
            pushNotificationPayload: userInfo,
            supportedOrientations: supportedOrientations)
        
        return chatViewController
    }
}
