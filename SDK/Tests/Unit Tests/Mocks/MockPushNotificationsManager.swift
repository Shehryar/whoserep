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
    private(set) var calledGetChatStatus = false
    private(set) var calledRequestAuthorization = false
    private(set) var calledRequestAuthorizationIfNeeded = false
    
    var session: Session? {
        didSet {
            if oldValue == nil && session != nil {
                register()
            }
        }
    }
    
    var deviceToken: String?
    
    var deviceId: Int?
    
    func register(user: ASAPPUser) {
        register()
    }
    
    private func register() {
        calledRegister = true
    }
    
    func getChatStatus(user: ASAPPUser, _ handler: @escaping ASAPP.ChatStatusHandler, _ failureHandler: ASAPP.FailureHandler?) {
        calledGetChatStatus = true
    }
    
    func requestAuthorization() {
        calledRequestAuthorization = true
    }
    
    func requestAuthorizationIfNeeded(after delay: DispatchTimeInterval) {
        calledRequestAuthorizationIfNeeded = true
    }
}
