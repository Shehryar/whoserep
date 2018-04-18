//
//  MockUserDefaults.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 4/12/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockUserDefaults: UserDefaultsProtocol {
    private(set) var calledSet = false
    private(set) var calledRemoveObject = false
    private(set) var calledObject = false
    private(set) var calledString = false
    private(set) var calledInteger = false
    var nextObject: Any?
    
    func set(_ value: Any?, forKey defaultName: String) {
        calledSet = true
        nextObject = value
    }
    
    func removeObject(forKey defaultName: String) {
        calledRemoveObject = true
        nextObject = nil
    }
    
    func object(forKey defaultName: String) -> Any? {
        calledObject = true
        return nextObject
    }
    
    func string(forKey defaultName: String) -> String? {
        calledString = true
        return nextObject as? String
    }
    
    func integer(forKey defaultName: String) -> Int {
        calledInteger = true
        return nextObject as? Int ?? 0
    }
    
    func cleanCalls() {
        calledSet = false
        calledRemoveObject = false
        calledObject = false
        calledString = false
        calledInteger = false
    }
    
    func clean() {
        cleanCalls()
        nextObject = nil
    }
}
