//
//  MockSavedSessionManager.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 1/2/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockSavedSessionManager: SavedSessionManagerProtocol {
    private(set) var calledClearSession = false
    private(set) var calledSave = false
    private(set) var calledGetSession = false
    var nextSession: Session?
    
    func clearSession() {
        calledClearSession = true
    }
    
    func save(session: Session?) {
        calledSave = true
    }
    
    func getSession() -> Session? {
        calledGetSession = true
        return nextSession
    }
}
