//
//  PushNotificationsManager.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 12/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation
import UserNotifications

protocol PushNotificationsManagerProtocol {
    var session: Session? { get set }
    var deviceToken: String? { get set }
    var deviceId: Int? { get set }
    func enableIfSessionExists()
    func register()
    func deregister()
    func getChatStatus(_ handler: @escaping ASAPP.ChatStatusHandler)
    func requestAuthorization()
    func requestAuthorizationIfNeeded(after delay: TimeInterval)
}

class PushNotificationsManager: PushNotificationsManagerProtocol {
    static let shared = PushNotificationsManager()
    
    private init() {}
    
    private let deviceTokenKey = "deviceToken"
    
    private let deviceIdKey = "deviceId"
    
    private let defaultParams: [String: Any] = [
        ASAPP.clientTypeKey: ASAPP.clientType,
        ASAPP.clientVersionKey: ASAPP.clientVersion
    ]
    
    var session: Session? {
        didSet {
            if oldValue != session && session != nil {
                register()
            }
        }
        
        willSet {
            if session != nil && newValue == nil {
                deregister()
            }
        }
    }
    
    var deviceToken: String? {
        get {
            return UserDefaults.standard.string(forKey: deviceTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: deviceTokenKey)
        }
    }
    
    var deviceId: Int? {
        get {
            let result = UserDefaults.standard.integer(forKey: deviceIdKey)
            return result != 0 ? result : nil
        }
        set {
            UserDefaults.standard.set(newValue, forKey: deviceIdKey)
        }
    }
    
    func enableIfSessionExists() {
        if session != nil {
            register()
        }
    }
    
    func register() {
        ASAPP.assertSetupComplete()
        
        guard let token = deviceToken,
              let session = session else {
            DebugLog.e(caller: self, "Could not enable push notifications. Need non-nil token and session.")
            return
        }
        
        let params: [String: Any] = [
            "DeviceType": "ios",
            "Token": token
        ]
        
        guard let headers = HTTPClient.shared.getHeaders(for: session) else {
            DebugLog.e(caller: self, "Could not enable push notifications because there was an error constructing the request headers.")
            return
        }
        
        HTTPClient.shared.sendRequest(method: .POST, path: "customer/push/register", headers: headers, params: params) { (data: [String: Any]?, response, error) in
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
            
            self.deviceId = deviceId
            DebugLog.d(caller: self, "Successfully enabled push notifications for token: \(token).\nDevice ID: \(deviceId)")
        }
    }
    
    func deregister() {
        ASAPP.assertSetupComplete()
        
        guard let session = session ?? SavedSessionManager.shared.getSession() else {
            DebugLog.e(caller: self, "Could not disable push notifications because no session was found.")
            return
        }
        
        guard let deviceId = self.deviceId else {
            DebugLog.e(caller: self, "Could not disable push notifications because no device ID was found.")
            return
        }
        
        let params: [String: Any] = ["DeviceId": deviceId]
        
        guard let headers = HTTPClient.shared.getHeaders(for: session) else {
            DebugLog.e(caller: self, "Could not disable push notifications because there was an error constructing the request headers.")
            return
        }
        
        HTTPClient.shared.sendRequest(method: .POST, path: "customer/push/deregister", headers: headers, params: params) { (data: [String: Any]?, response, error) in
            guard data != nil else {
                if let error = error {
                    DebugLog.e(error)
                } else {
                    DebugLog.e("Received error trying to disable push notifications.\n\(String(describing: response))")
                }
                return
            }
            
            self.deviceId = nil
            DebugLog.d(caller: self, "Successfully disabled push notifications for device ID: \(deviceId)")
        }
    }
    
    func getChatStatus(_ handler: @escaping ASAPP.ChatStatusHandler) {
        ASAPP.assertSetupComplete()
        
        guard let session = session ?? SavedSessionManager.shared.getSession() else {
            DebugLog.e(caller: self, "Could not get chat status because no session was found.")
            return
        }
        
        guard let headers = HTTPClient.shared.getHeaders(for: session) else {
            DebugLog.e(caller: self, "Could not get chat status because there was an error constructing the request headers.")
            return
        }
        
        HTTPClient.shared.sendRequest(method: .GET, path: "customer/push/chatStatus", headers: headers) { (data: [String: Any]?, response, error) in
            guard let data = data,
                  let count = data["UnreadMessages"] as? Int,
                  let isLiveChat = data["IsLiveChat"] as? Bool else {
                if let error = error {
                    DebugLog.e(error)
                } else {
                    DebugLog.e("Received error trying to get chat status.\n\(String(describing: response))")
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
    
    func requestAuthorizationIfNeeded(after delay: TimeInterval = 0) {
        func request() {
            Dispatcher.delay(delay * 1000.0) { [weak self] in
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
}
