//
//  PushNotificationsManager.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 12/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation
import UserNotifications

class PushNotificationsManager {
    static let deviceTokenKey = "deviceToken"
    static let deviceIdKey = "deviceId"
    
    static var session: Session? {
        didSet {
            if oldValue == nil && session != nil {
                PushNotificationsManager.register()
            }
        }
        
        willSet {
            if session != nil && newValue == nil {
                PushNotificationsManager.deregister()
            }
        }
    }
    
    static var deviceToken: String? {
        get {
            return UserDefaults.standard.string(forKey: deviceTokenKey)
        }
        set {
            UserDefaults.standard.set(deviceToken, forKey: deviceTokenKey)
        }
    }
    
    static var deviceId: Int? {
        get {
            let result = UserDefaults.standard.integer(forKey: deviceIdKey)
            return result != 0 ? result : nil
        }
        set {
            UserDefaults.standard.set(deviceId, forKey: deviceIdKey)
        }
    }
    
    static let defaultParams: [String: Any] = [
        ASAPP.clientTypeKey: ASAPP.clientType,
        ASAPP.clientVersionKey: ASAPP.clientVersion
    ]
    
    private class func getHeaders(for session: Session) -> [String: String]? {
        let passwordPayload: [String: Any] = [
            "CustomerId": session.customer.id,
            "SessionTime": session.auth.time,
            "SessionSecret": session.auth.secret
        ]
        
        guard let passwordPayloadData = try? JSONSerialization.data(withJSONObject: passwordPayload, options: []),
              let passwordPayloadString = String(data: passwordPayloadData, encoding: .utf8) else {
            DebugLog.e(caller: self, "Could not serialize the password payload.")
            return nil
        }
        
        let authPayloadString = ":\(passwordPayloadString)"
        guard let authPayloadData = authPayloadString.data(using: .utf8) else {
            DebugLog.e(caller: self, "Could not serialize the authentication payload.")
            return nil
        }
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Basic \(authPayloadData.base64EncodedString())"
        ]
        
        return headers
    }
    
    class func enableIfSessionExists() {
        if session != nil {
            register()
        }
    }
    
    class func register() {
        ASAPP.assertSetupComplete()
        
        let url = URL(string: "https://\(ASAPP.config.apiHostName)/api/http/v1/push/register")!
        
        guard let token = self.deviceToken,
              let session = PushNotificationsManager.session else {
            DebugLog.e(caller: self, "Could not enable push notifications. Need non-nil token and session.")
            return
        }
        
        var params = defaultParams
        params["DeviceType"] = "ios"
        params["Token"] = token
        
        guard let headers = getHeaders(for: session) else {
            DebugLog.e(caller: self, "Could not enable push notifications because there was an error constructing the request headers.")
            return
        }
        
        HTTPClient.shared.sendRequest(method: .POST, url: url, headers: headers, params: params) { data, response, error in
            guard let data = data,
                  (data["Success"] as? Bool) == true,
                  let device = data["Device"] as? [String: Any],
                  let deviceId = device["DeviceID"] as? Int else {
                if let error = error {
                    DebugLog.e(error)
                } else {
                    DebugLog.e("Received error trying to enable push notifications.\n\(String(describing: response))")
                }
                return
            }
            
            self.deviceToken = nil
            self.deviceId = deviceId
            DebugLog.d(caller: self, "Successfully enabled push notifications for token: \(token)")
        }
    }
    
    class func deregister() {
        ASAPP.assertSetupComplete()
        
        let url = URL(string: "https://\(ASAPP.config.apiHostName)/api/http/v1/push/deregister")!
        
        guard let session = PushNotificationsManager.session ?? SavedSessionManager.getSession() else {
            DebugLog.e(caller: self, "Could not disable push notifications because no session was found.")
            return
        }
        
        guard let deviceId = self.deviceId else {
            DebugLog.e(caller: self, "Could not disable push notifications because no device ID was found.")
            return
        }
        
        var params = defaultParams
        params["DeviceId"] = deviceId
        
        guard let headers = getHeaders(for: session) else {
            DebugLog.e(caller: self, "Could not disable push notifications because there was an error constructing the request headers.")
            return
        }
        
        HTTPClient.shared.sendRequest(method: .POST, url: url, headers: headers, params: params) { data, response, error in
            guard let data = data,
                  (data["Success"] as? Bool) == true else {
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
    
    class func getUnreadMessagesCount(_ handler: @escaping ASAPP.UnreadMessagesHandler) {
        ASAPP.assertSetupComplete()
        
        let url = URL(string: "https://\(ASAPP.config.apiHostName)/api/http/v1/push/offlineMessageCount")!
        
        guard let session = PushNotificationsManager.session ?? SavedSessionManager.getSession() else {
            DebugLog.e(caller: self, "Could not get number of unread messages because no session was found.")
            return
        }
        
        let params = defaultParams
        
        guard let headers = getHeaders(for: session) else {
            DebugLog.e(caller: self, "Could not get number of unread messages because there was an error constructing the request headers.")
            return
        }
        
        HTTPClient.shared.sendRequest(method: .GET, url: url, headers: headers, params: params) { data, response, error in
            guard let data = data,
                  (data["Success"] as? Bool) == true,
                  let count = data["Count"] as? Int else {
                if let error = error {
                    DebugLog.e(error)
                } else {
                    DebugLog.e("Received error trying to get number of unread messages.\n\(String(describing: response))")
                }
                return
            }
            
            handler(count)
        }
    }
    
    class func requestAuthorization() {
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
    
    class func requestAuthorizationIfNeeded(after delay: TimeInterval = 0) {
        func request() {
            Dispatcher.delay(delay * 1000.0) {
                requestAuthorization()
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
