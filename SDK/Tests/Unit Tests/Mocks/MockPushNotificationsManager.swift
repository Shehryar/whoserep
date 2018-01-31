//
//  MockPushNotificationsManager.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 1/2/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockPushNotificationsManager: PushNotificationsManagerProtocol {
    private(set) var calledEnableIfSessionExists = false
    private(set) var calledRegister = false
    private(set) var calledDeregister = false
    private(set) var calledGetUnreadMessagesCount = false
    private(set) var calledRequestAuthorization = false
    private(set) var calledRequestAuthorizaitonIfNeeded = false
    
    var session: Session? {
        didSet {
            if oldValue == nil && session != nil {
                register()
            }
        }
        
        willSet {
            if session != nil && newValue == nil {
                deregister()
            }
        }
    }
    
    var deviceToken: String?
    
    var deviceId: Int?
    
    func enableIfSessionExists() {
        if session != nil {
            register()
        }
    }
    
    func register() {
        calledRegister = true
    }
    
    func deregister() {
        calledDeregister = true
    }
    
    func getUnreadMessagesCount(_ handler: @escaping ASAPP.UnreadMessagesHandler) {
        calledGetUnreadMessagesCount = true
    }
    
    func requestAuthorization() {
        calledRequestAuthorization = true
    }
    
    func requestAuthorizationIfNeeded(after delay: TimeInterval) {
        calledRequestAuthorizaitonIfNeeded = true
    }
}
