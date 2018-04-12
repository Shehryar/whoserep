//
//  MockCodableStorage.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 3/6/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockCodableStorage: CodableStorageProtocol {
    private(set) var calledStore = false
    private(set) var calledRetrieve = false
    private(set) var calledRemove = false
    var nextRetrievedObject: Storable?
    var nextExtantFileName: String?
    var nextRemoveShouldThrow = false
    var nextStoreShouldThrow = false
    var nextRetrieveShouldThrow = false
    
    func store<T: Storable & Encodable>(_ object: T, as fileName: String, to directory: FileManager.SearchPathDirectory? = nil) throws {
        calledStore = true
        
        if nextStoreShouldThrow {
            throw StorageError.couldNotWriteFile("")
        }
        
        nextRetrievedObject = object
        nextExtantFileName = fileName
    }
    
    func retrieve<T: Storable & Decodable>(_ fileName: String, as type: T.Type, from directory: FileManager.SearchPathDirectory? = nil) throws -> T? {
        calledRetrieve = true
        
        if nextRetrieveShouldThrow {
            throw StorageError.couldNotReadFile("")
        }
        
        return fileName == nextExtantFileName ? nextRetrievedObject as? T : nil
    }
    
    func remove(_ fileName: String, from directory: FileManager.SearchPathDirectory) throws {
        calledRemove = true
        
        if nextRemoveShouldThrow {
            throw StorageError.couldNotDeleteFile("")
        }
        
        if fileName == nextExtantFileName {
            nextRetrievedObject = nil
            nextExtantFileName = nil
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
        nextExtantFileName = nil
        nextRemoveShouldThrow = false
        nextStoreShouldThrow = false
        nextRetrieveShouldThrow = false
    }
}
