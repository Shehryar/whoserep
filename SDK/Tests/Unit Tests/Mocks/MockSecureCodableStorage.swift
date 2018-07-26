//
//  MockSecureCodableStorage.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 7/24/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockSecureCodableStorage: SecureCodableStorageProtocol {
    private(set) var calledStore = false
    private(set) var calledRetrieve = false
    private(set) var calledRemove = false
    var nextRetrievedObject: Codable?
    var nextExtantKey: String?
    var nextRemoveShouldThrow = false
    var nextStoreShouldThrow = false
    var nextRetrieveShouldThrow = false
    
    func store<T: Codable>(_ object: T, as key: String) throws {
        calledStore = true
        
        if nextStoreShouldThrow {
            throw SecureStorageError.couldNotStoreObject("")
        }
        
        nextRetrievedObject = object
        nextExtantKey = key
    }
    
    func retrieve<T: Codable>(_ key: String, as type: T.Type) throws -> T? {
        calledRetrieve = true
        
        if nextRetrieveShouldThrow {
            throw SecureStorageError.couldNotRetrieveObject("")
        }
        
        return key == nextExtantKey ? nextRetrievedObject as? T : nil
    }
    
    func remove(_ key: String) throws {
        calledRemove = true
        
        if nextRemoveShouldThrow {
            throw SecureStorageError.couldNotDeleteObject("")
        }
        
        if key == nextExtantKey {
            nextRetrievedObject = nil
            nextExtantKey = nil
        }
    }
    
    func cleanCalls() {
        calledStore = false
        calledRetrieve = false
        calledRemove = false
    }
    
    func clean() {
        cleanCalls()
        nextRetrievedObject = nil
        nextExtantKey = nil
        nextRemoveShouldThrow = false
        nextStoreShouldThrow = false
        nextRetrieveShouldThrow = false
    }
}
