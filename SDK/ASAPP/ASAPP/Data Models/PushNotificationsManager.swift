//
//  PushNotificationsManager.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 12/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation
import UserNotifications

protocol UserDefaultsProtocol {
    func set(_ value: Any?, forKey defaultName: String)
    func removeObject(forKey defaultName: String)
    func object(forKey defaultName: String) -> Any?
    func string(forKey defaultName: String) -> String?
    func integer(forKey defaultName: String) -> Int
}

extension UserDefaults: UserDefaultsProtocol {}

protocol PushNotificationsManagerProtocol {
    var session: Session? { get set }
    func register(user: ASAPPUser, deviceIdentifier: String)
    func getChatStatus(user: ASAPPUser, _ handler: @escaping ASAPP.ChatStatusHandler, _ failureHandler: ASAPP.FailureHandler?)
    func requestAuthorization()
    func requestAuthorizationIfNeeded(after delay: DispatchTimeInterval)
}

extension PushNotificationsManagerProtocol {
    func getChatStatus(user: ASAPPUser, _ handler: @escaping ASAPP.ChatStatusHandler) {
        return getChatStatus(user: user, handler, nil)
    }
}

class PushNotificationsManager: PushNotificationsManagerProtocol {
    enum PushNotificationsManagerError: Error {
        case getChatStatusError
    }
    
    static let shared = PushNotificationsManager()
    
    private let userDefaults: UserDefaultsProtocol
    
    init(userDefaults: UserDefaultsProtocol = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    private static let deviceTokenKey = "deviceToken"
    private static let asappDeviceKey = "ASAPPDevice"
    private let deviceIdKey = "deviceId"
    
    private let defaultParams: [String: Any] = [
        ASAPP.clientTypeKey: ASAPP.clientType,
        ASAPP.clientVersionKey: ASAPP.clientVersion,
        ASAPP.partnerAppVersionKey: ASAPP.partnerAppVersion
    ]
    
    var session: Session? {
        didSet {
            if session != nil && !(oldValue?.customerMatches(primaryId: session?.customerPrimaryIdentifier) ?? false) {
                register()
            }
        }
    }
    
    var token: String? {
        return recipient?.registeredId
    }
    
    var recipient: PushNotificationRecipient? {
        get {
            return userDefaults.object(forKey: PushNotificationsManager.asappDeviceKey) as? PushNotificationRecipient
        }
        set {
            userDefaults.set(newValue, forKey: PushNotificationsManager.asappDeviceKey)
        }
    }
    
    private func ensureAuth(user: ASAPPUser, success: @escaping (Session) -> Void, failure: @escaping () -> Void) {
        HTTPClient.shared.authenticate(as: user, contextNeedsRefresh: false, shouldRetry: false) { result in
            switch result {
            case .success(let session):
                success(session)
            default:
                failure()
            }
        }
    }
    
    func register(user: ASAPPUser, deviceIdentifier: String) {
        
        if let savedDevice = recipient {
            if deviceIdentifier == savedDevice.registeredId && user.userIdentifier == savedDevice.userId {
                return
            }
        }
        
        if let session = session,
           session.authenticatedTime.addingTimeInterval(60) >= Date(),
           session.customerMatches(primaryId: user.userIdentifier) {
            register()
        } else {
            ensureAuth(user: user, success: { [weak self] session in
                self?.session = session
            }, failure: {
                DebugLog.e(caller: self, "Could not authenticate before enabling push notifications.")
            })
        }
    }
    
    private func register() {
        guard let deviceToken = token,
            let session = session else {
            DebugLog.e(caller: self, "Could not enable push notifications. Need non-nil token and session.")
            return
        }
        
        let params: [String: Any] = [
            "DeviceType": "ios",
            "Token": deviceToken
        ]
        
        guard let headers = HTTPClient.shared.getHeaders(for: session) else {
            DebugLog.e(caller: self, "Could not enable push notifications because there was an error constructing the request headers.")
            return
        }
        
        HTTPClient.shared.sendRequest(method: .POST, path: "customer/pushregister", headers: headers, params: params) { [weak self] (data: [String: Any]?, response, error) in
            guard let data = data,
                  let device = data["Device"] as? [String: Any],
                  let deviceId = device["DeviceID"] as? Int else {
                if let error = error {
                    DebugLog.e(error)
                } else {
                    DebugLog.e("Received error trying to enable push notifications.\n\(String(describing: response))")
                }
                return
            }
            
            PushNotificationsManager.clearRegisteredDevice()
            self?.recipient = PushNotificationRecipient(userId: ASAPP.user.userIdentifier, registeredId: deviceToken, assignedId: deviceId)
            DebugLog.d(caller: self, "Successfully enabled push notifications for token: \(deviceToken).\nDevice ID: \(deviceId)")
        }
    }
    
    func getChatStatus(user: ASAPPUser, _ handler: @escaping ASAPP.ChatStatusHandler, _ failureHandler: ASAPP.FailureHandler? = nil) {
        if let session = session,
            session.authenticatedTime.addingTimeInterval(60) >= Date(),
            session.customerMatches(primaryId: user.userIdentifier) {
            getChatStatus(handler, failureHandler)
        } else {
            ensureAuth(user: user, success: { [weak self] session in
                self?.session = session
                self?.getChatStatus(handler, failureHandler)
            }, failure: {
                DebugLog.e(caller: self, "Could not authenticate before enabling push notifications.")
            })
        }
    }

    private func getChatStatus(_ handler: @escaping ASAPP.ChatStatusHandler, _ failureHandler: ASAPP.FailureHandler?) {
        ASAPP.assertSetupComplete()
        
        guard let session = session ?? SavedSessionManager.shared.getSession() else {
            DebugLog.e(caller: self, "Could not get chat status because no session was found.")
            return
        }
        
        guard let headers = HTTPClient.shared.getHeaders(for: session) else {
            DebugLog.e(caller: self, "Could not get chat status because there was an error constructing the request headers.")
            return
        }
        
        HTTPClient.shared.sendRequest(method: .POST, path: "customer/pushchatstatus", headers: headers) { (data: [String: Any]?, response, error) in
            guard let data = data,
                  let count = data["UnreadMessages"] as? Int,
                  let isLiveChat = data["IsLiveChat"] as? Bool else {
                if let error = error {
                    DebugLog.e(error)
                    failureHandler?(PushNotificationsManagerError.getChatStatusError)
                } else {
                    DebugLog.e("Received error trying to get chat status.\n\(String(describing: response))")
                    failureHandler?(PushNotificationsManagerError.getChatStatusError)
                }
                return
            }
            
            handler(count, isLiveChat)
        }
    }
    
    func requestAuthorization() {
        guard ASAPP.shouldRequestNotificationAuthorization else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                guard error == nil else {
                    DebugLog.e("There was an error requesting notification authorization.")
                    return
                }
                
                if granted {
                    Dispatcher.performOnMainThread {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    ASAPP.notificationAuthorizationDenied?()
                }
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func requestAuthorizationIfNeeded(after delay: DispatchTimeInterval = .seconds(0)) {
        func request() {
            Dispatcher.delay(delay) { [weak self] in
                self?.requestAuthorization()
            }
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus != .authorized {
                    request()
                }
            }
        } else {
            if !UIApplication.shared.isRegisteredForRemoteNotifications {
                request()
            }
        }
    }
    
    class func clearRegisteredDevice() {
        UserDefaults.standard.removeObject(forKey: PushNotificationsManager.asappDeviceKey)
    }
}
