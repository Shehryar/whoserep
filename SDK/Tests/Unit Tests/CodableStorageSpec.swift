//
//  CodableStorageSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 3/6/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

struct ExpirableObject: Codable {}

extension ExpirableObject: Storable {
    static var defaultDirectory = FileManager.SearchPathDirectory.documentDirectory
}

extension ExpirableObject: Expirable {
    static var timeToLive: TimeInterval = 10
}

// swiftlint:disable:next type_body_length
class CodableStorageSpec: QuickSpec {
    override func spec() {
        var sessionCounter = 0
        
        func createSession(from dict: [String: Any]) -> Session? {
            let decoder = JSONDecoder()
            
            guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
                var session = try? decoder.decode(Session.self, from: data) else {
                    return nil
            }
            
            session.fullInfo = data
            
            return session
        }
        
        func createTestSession() -> Session {
            let dict = [
                "authenticated_time": 327511937000000,
                "customer_primary_identifier": "foo\(sessionCounter)",
                "customer_id": 9000,
                "customer_guid": "deadbeef",
                "company_id": 42,
                "session_token": "deadbeef",
                "session_id": "dead-beef"
            ] as [String: Any]
            
            sessionCounter += 1
            
            return createSession(from: dict)!
        }
        
        describe("CodableStorage") {
            context(".store(_:as:to:)") {
                context("with everything as expected") {
                    it("stores the object properly") {
                        let mockFileManager = MockFileManager()
                        mockFileManager.nextUrls = [URL(fileURLWithPath: "testDirectory")]
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        let object = createTestSession()
                        
                        // swiftlint:disable:next force_try
                        try! codableStorage.store(object, as: fileName)
                        
                        expect(mockFileManager.calledUrls).to(equal(true))
                        expect(mockFileManager.calledFileExists).to(equal(true))
                        expect(mockFileManager.calledRemoveItem).to(equal(false))
                        expect(mockFileManager.calledCreateFile).to(equal(true))
                        expect(mockFileManager.calledAttributesOfItem).to(equal(false))
                        expect(mockFileManager.calledContents).to(equal(false))
                    }
                }
                
                context("without an available directory") {
                    it("throws an error") {
                        let mockFileManager = MockFileManager()
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        let object = createTestSession()
                        
                        do {
                            try codableStorage.store(object, as: fileName)
                        } catch {
                            expect(error).to(beAKindOf(StorageError.self))
                            expect(mockFileManager.calledUrls).to(equal(true))
                            expect(mockFileManager.calledFileExists).to(equal(false))
                            expect(mockFileManager.calledRemoveItem).to(equal(false))
                            expect(mockFileManager.calledCreateFile).to(equal(false))
                            expect(mockFileManager.calledAttributesOfItem).to(equal(false))
                            expect(mockFileManager.calledContents).to(equal(false))
                        }
                    }
                }
                
                context("with an existing file") {
                    it("stores the object properly") {
                        let mockFileManager = MockFileManager()
                        let url = URL(fileURLWithPath: "testDirectory")
                        mockFileManager.nextUrls = [url]
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        mockFileManager.nextExtantFilePath = url.appendingPathComponent(fileName).path
                        let object = createTestSession()
                        
                        // swiftlint:disable:next force_try
                        try! codableStorage.store(object, as: fileName)
                        
                        expect(mockFileManager.calledUrls).to(equal(true))
                        expect(mockFileManager.calledFileExists).to(equal(true))
                        expect(mockFileManager.calledRemoveItem).to(equal(true))
                        expect(mockFileManager.calledCreateFile).to(equal(true))
                        expect(mockFileManager.calledAttributesOfItem).to(equal(false))
                        expect(mockFileManager.calledContents).to(equal(false))
                    }
                }
                
                context("with an existing file that cannot be removed") {
                    it("throws an error") {
                        let mockFileManager = MockFileManager()
                        let url = URL(fileURLWithPath: "testDirectory")
                        mockFileManager.nextUrls = [url]
                        mockFileManager.nextRemoveItemShouldThrow = true
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        mockFileManager.nextExtantFilePath = url.appendingPathComponent(fileName).path
                        let object = createTestSession()
                        
                        do {
                            try codableStorage.store(object, as: fileName)
                        } catch {
                            expect(error).to(beAKindOf(StorageError.self))
                            expect(mockFileManager.calledUrls).to(equal(true))
                            expect(mockFileManager.calledFileExists).to(equal(true))
                            expect(mockFileManager.calledRemoveItem).to(equal(true))
                            expect(mockFileManager.calledCreateFile).to(equal(false))
                            expect(mockFileManager.calledAttributesOfItem).to(equal(false))
                            expect(mockFileManager.calledContents).to(equal(false))
                        }
                    }
                }
            }
            
            context(".retrieve(_:as:from:)") {
                context("with everything as expected") {
                    it("retrieves the object properly") {
                        let mockFileManager = MockFileManager()
                        mockFileManager.nextUrls = [URL(fileURLWithPath: "testDirectory")]
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        let object = createTestSession()
                        
                        // swiftlint:disable:next force_try
                        try! codableStorage.store(object, as: fileName)
                        
                        mockFileManager.cleanCalls()
                        
                        // swiftlint:disable:next force_try
                        let retrieved = try! codableStorage.retrieve(fileName, as: Session.self)
                        
                        expect(retrieved).to(equal(object))
                        expect(mockFileManager.calledUrls).to(equal(true))
                        expect(mockFileManager.calledFileExists).to(equal(true))
                        expect(mockFileManager.calledRemoveItem).to(equal(false))
                        expect(mockFileManager.calledCreateFile).to(equal(false))
                        expect(mockFileManager.calledAttributesOfItem).to(equal(false))
                        expect(mockFileManager.calledContents).to(equal(true))
                    }
                }
                
                context("without an available directory") {
                    it("throws an error") {
                        let mockFileManager = MockFileManager()
                        mockFileManager.nextUrls = [URL(fileURLWithPath: "testDirectory")]
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        let object = createTestSession()
                        
                        // swiftlint:disable:next force_try
                        try! codableStorage.store(object, as: fileName)
                        
                        mockFileManager.cleanCalls()
                        mockFileManager.nextUrls = []
                        
                        do {
                            _ = try codableStorage.retrieve(fileName, as: Session.self)
                        } catch {
                            expect(error).to(beAKindOf(StorageError.self))
                            expect(mockFileManager.calledUrls).to(equal(true))
                            expect(mockFileManager.calledFileExists).to(equal(false))
                            expect(mockFileManager.calledRemoveItem).to(equal(false))
                            expect(mockFileManager.calledCreateFile).to(equal(false))
                            expect(mockFileManager.calledAttributesOfItem).to(equal(false))
                            expect(mockFileManager.calledContents).to(equal(false))
                        }
                    }
                }
                
                context("without an existing file") {
                    it("returns nil") {
                        let mockFileManager = MockFileManager()
                        mockFileManager.nextUrls = [URL(fileURLWithPath: "testDirectory")]
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        
                        // swiftlint:disable:next force_try
                        let retrieved = try! codableStorage.retrieve(fileName, as: Session.self)
                        
                        expect(retrieved).to(beNil())
                        expect(mockFileManager.calledUrls).to(equal(true))
                        expect(mockFileManager.calledFileExists).to(equal(true))
                        expect(mockFileManager.calledRemoveItem).to(equal(false))
                        expect(mockFileManager.calledCreateFile).to(equal(false))
                        expect(mockFileManager.calledAttributesOfItem).to(equal(false))
                        expect(mockFileManager.calledContents).to(equal(false))
                    }
                }
                
                context("with an expired file") {
                    it("returns nil") {
                        let mockFileManager = MockFileManager()
                        mockFileManager.nextUrls = [URL(fileURLWithPath: "testDirectory")]
                        mockFileManager.nextAttributesOfItem = [
                            FileAttributeKey.modificationDate: Date(timeIntervalSinceNow: ExpirableObject.timeToLive * -2)
                        ]
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        let object = ExpirableObject()
                        
                        // swiftlint:disable:next force_try
                        try! codableStorage.store(object, as: fileName)
                        
                        mockFileManager.cleanCalls()
                        
                        // swiftlint:disable:next force_try
                        let retrieved = try! codableStorage.retrieve(fileName, as: ExpirableObject.self)
                        
                        expect(retrieved).to(beNil())
                        expect(mockFileManager.calledUrls).to(equal(true))
                        expect(mockFileManager.calledFileExists).to(equal(true))
                        expect(mockFileManager.calledRemoveItem).to(equal(true))
                        expect(mockFileManager.calledCreateFile).to(equal(false))
                        expect(mockFileManager.calledAttributesOfItem).to(equal(true))
                        expect(mockFileManager.calledContents).to(equal(true))
                    }
                }
                
                context("with an expired file that cannot be removed") {
                    it("throws an error") {
                        let mockFileManager = MockFileManager()
                        mockFileManager.nextUrls = [URL(fileURLWithPath: "testDirectory")]
                        mockFileManager.nextAttributesOfItem = [
                            FileAttributeKey.modificationDate: Date(timeIntervalSinceNow: ExpirableObject.timeToLive * -2)
                        ]
                        mockFileManager.nextRemoveItemShouldThrow = true
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        let object = ExpirableObject()
                        
                        // swiftlint:disable:next force_try
                        try! codableStorage.store(object, as: fileName)
                        
                        mockFileManager.cleanCalls()
                        
                        do {
                            _ = try codableStorage.retrieve(fileName, as: ExpirableObject.self)
                        } catch {
                            expect(error).to(beAKindOf(StorageError.self))
                            expect(mockFileManager.calledUrls).to(equal(true))
                            expect(mockFileManager.calledFileExists).to(equal(true))
                            expect(mockFileManager.calledRemoveItem).to(equal(true))
                            expect(mockFileManager.calledCreateFile).to(equal(false))
                            expect(mockFileManager.calledAttributesOfItem).to(equal(true))
                            expect(mockFileManager.calledContents).to(equal(true))
                        }
                    }
                }
                
                context("with an empty file") {
                    it("returns nil") {
                        let mockFileManager = MockFileManager()
                        mockFileManager.nextUrls = [URL(fileURLWithPath: "testDirectory")]
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        let object = createTestSession()
                        
                        // swiftlint:disable:next force_try
                        try! codableStorage.store(object, as: fileName)
                        
                        mockFileManager.cleanCalls()
                        mockFileManager.nextContents = nil
                        
                        // swiftlint:disable:next force_try
                        let retrieved = try! codableStorage.retrieve(fileName, as: Session.self)
                        
                        expect(retrieved).to(beNil())
                        expect(mockFileManager.calledUrls).to(equal(true))
                        expect(mockFileManager.calledFileExists).to(equal(true))
                        expect(mockFileManager.calledRemoveItem).to(equal(false))
                        expect(mockFileManager.calledCreateFile).to(equal(false))
                        expect(mockFileManager.calledAttributesOfItem).to(equal(false))
                        expect(mockFileManager.calledContents).to(equal(true))
                    }
                }
            }
            
            context(".remove(_:from:)") {
                context("with everything as expected") {
                    it("removes the object properly") {
                        let mockFileManager = MockFileManager()
                        mockFileManager.nextUrls = [URL(fileURLWithPath: "testDirectory")]
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        let object = createTestSession()
                        
                        // swiftlint:disable:next force_try
                        try! codableStorage.store(object, as: fileName)
                        
                        mockFileManager.cleanCalls()
                        
                        // swiftlint:disable:next force_try
                        try! codableStorage.remove(fileName, from: Session.defaultDirectory)
                        
                        expect(mockFileManager.calledUrls).to(equal(true))
                        expect(mockFileManager.calledFileExists).to(equal(true))
                        expect(mockFileManager.calledRemoveItem).to(equal(true))
                        expect(mockFileManager.calledCreateFile).to(equal(false))
                        expect(mockFileManager.calledAttributesOfItem).to(equal(false))
                        expect(mockFileManager.calledContents).to(equal(false))
                        
                        mockFileManager.cleanCalls()
                        
                        // swiftlint:disable:next force_try
                        let retrieved = try! codableStorage.retrieve(fileName, as: Session.self)
                        
                        expect(retrieved).to(beNil())
                    }
                }
                
                context("without an available directory") {
                    it("throws an error") {
                        let mockFileManager = MockFileManager()
                        mockFileManager.nextUrls = [URL(fileURLWithPath: "testDirectory")]
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        let object = createTestSession()
                        
                        // swiftlint:disable:next force_try
                        try! codableStorage.store(object, as: fileName)
                        
                        mockFileManager.cleanCalls()
                        mockFileManager.nextUrls = []
                        
                        do {
                            _ = try codableStorage.remove(fileName, from: Session.defaultDirectory)
                        } catch {
                            expect(error).to(beAKindOf(StorageError.self))
                            expect(mockFileManager.calledUrls).to(equal(true))
                            expect(mockFileManager.calledFileExists).to(equal(false))
                            expect(mockFileManager.calledRemoveItem).to(equal(false))
                            expect(mockFileManager.calledCreateFile).to(equal(false))
                            expect(mockFileManager.calledAttributesOfItem).to(equal(false))
                            expect(mockFileManager.calledContents).to(equal(false))
                        }
                    }
                }
                
                context("with a file that cannot be removed") {
                    it("throws an error") {
                        let mockFileManager = MockFileManager()
                        mockFileManager.nextUrls = [URL(fileURLWithPath: "testDirectory")]
                        let codableStorage = CodableStorage(fileManager: mockFileManager)
                        let fileName = "foo"
                        let object = createTestSession()
                        
                        // swiftlint:disable:next force_try
                        try! codableStorage.store(object, as: fileName)
                        
                        mockFileManager.cleanCalls()
                        mockFileManager.nextRemoveItemShouldThrow = true
                        
                        do {
                            _ = try codableStorage.remove(fileName, from: Session.defaultDirectory)
                        } catch {
                            expect(error).to(beAKindOf(StorageError.self))
                            expect(mockFileManager.calledUrls).to(equal(true))
                            expect(mockFileManager.calledFileExists).to(equal(true))
                            expect(mockFileManager.calledRemoveItem).to(equal(true))
                            expect(mockFileManager.calledCreateFile).to(equal(false))
                            expect(mockFileManager.calledAttributesOfItem).to(equal(false))
                            expect(mockFileManager.calledContents).to(equal(false))
                        }
                    }
                }
            }
        }
    }
}
