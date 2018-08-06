//
//  MockSecureCodableStorage.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 7/24/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockSecureStorage: SecureStorageProtocol {
    private(set) var calledStore = false
    private(set) var calledRetrieve = false
    private(set) var calledRemove = false
    var nextRetrievedCodable: Codable?
    var nextRetrievedData: Data?
    var nextExtantKey: String?
    var nextRemoveShouldThrow = false
    var nextStoreShouldThrow = false
    var nextRetrieveShouldThrow = false
    
    func store(data: Data, as key: String) throws {
        calledStore = true
        
        if nextStoreShouldThrow {
            throw SecureStorageError.couldNotStoreObject("")
        }
        
        nextRetrievedData = data
        nextExtantKey = key
    }
    
    func store<T: Codable>(_ object: T, as key: String) throws {
        calledStore = true
        
        if nextStoreShouldThrow {
            throw SecureStorageError.couldNotStoreObject("")
        }
        
        nextRetrievedCodable = object
        nextExtantKey = key
    }
    
    func retrieve(_ key: String) throws -> Data {
        if nextRetrieveShouldThrow {
            throw SecureStorageError.couldNotRetrieveObject("")
        }
        
        if let data = nextRetrievedData {
            return data
        } else {
            throw SecureStorageError.couldNotRetrieveObject("")
        }
    }
    
    func retrieve<T: Codable>(_ key: String, as type: T.Type) throws -> T {
        calledRetrieve = true
        
        if nextRetrieveShouldThrow {
            throw SecureStorageError.couldNotRetrieveObject("")
        }
        
        if key == nextExtantKey {
            if let object = nextRetrievedCodable as? T {
                return object
            } else {
                throw SecureStorageError.couldNotRetrieveObject("")
            }
        }
        
        throw SecureStorageError.couldNotRetrieveObject("")
    }
    
    func remove(_ key: String) throws {
        calledRemove = true
        
        if nextRemoveShouldThrow {
            throw SecureStorageError.couldNotDeleteObject("")
        }
        
        if key == nextExtantKey {
            nextRetrievedCodable = nil
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
        nextRetrievedCodable = nil
        nextExtantKey = nil
        nextRemoveShouldThrow = false
        nextStoreShouldThrow = false
        nextRetrieveShouldThrow = false
    }
}
