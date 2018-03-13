//
//  MockFileManager.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 3/6/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

@testable import ASAPP

class MockFileManager: FileManagerProtocol {
    private(set) var calledUrls = false
    private(set) var calledFileExists = false
    private(set) var calledRemoveItem = false
    private(set) var calledCreateFile = false
    private(set) var calledContents = false
    private(set) var calledAttributesOfItem = false
    var nextUrls: [URL] = []
    var nextExtantFilePath: String?
    var nextContents: Data?
    var nextAttributesOfItem: [FileAttributeKey: Any] = [:]
    var nextRemoveItemShouldThrow = false
    
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        calledUrls = true
        return nextUrls
    }
    
    func fileExists(atPath path: String) -> Bool {
        calledFileExists = true
        return nextExtantFilePath == path
    }
    
    func removeItem(at URL: URL) throws {
        calledRemoveItem = true
        
        if nextRemoveItemShouldThrow {
            throw StorageError.couldNotDeleteFile("")
        }
        
        if URL.path == nextExtantFilePath {
            nextExtantFilePath = nil
            nextContents = nil
            nextAttributesOfItem = [:]
        }
    }
    
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey: Any]? = nil) -> Bool {
        calledCreateFile = true
        nextExtantFilePath = path
        nextContents = data
        nextAttributesOfItem = nextAttributesOfItem.merging(attr ?? [:], uniquingKeysWith: { (_, new) -> Any in
            return new
        })
        return true
    }
    
    func contents(atPath path: String) -> Data? {
        calledContents = true
        return nextExtantFilePath == path ? nextContents : nil
    }
    
    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        calledAttributesOfItem = true
        return nextExtantFilePath == path ? nextAttributesOfItem : [:]
    }
    
    func cleanCalls() {
        calledUrls = false
        calledFileExists = false
        calledRemoveItem = false
        calledCreateFile = false
        calledContents = false
        calledAttributesOfItem = false
    }
    
    func clean() {
        cleanCalls()
        nextUrls = []
        nextExtantFilePath = nil
        nextContents = nil
        nextAttributesOfItem = [:]
        nextRemoveItemShouldThrow = false
    }
}
