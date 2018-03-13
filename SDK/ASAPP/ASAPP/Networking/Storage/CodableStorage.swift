//
//  CodableStorage.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

protocol Storable {
    static var defaultDirectory: FileManager.SearchPathDirectory { get }
}

protocol Expirable {
    static var timeToLive: TimeInterval { get }
}

protocol FileManagerProtocol {
    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func fileExists(atPath path: String) -> Bool
    func removeItem(at URL: URL) throws
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey: Any]?) -> Bool
    func contents(atPath path: String) -> Data?
    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any]
}

extension FileManagerProtocol {
    @discardableResult
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey: Any]? = nil) -> Bool {
        return createFile(atPath: path, contents: data, attributes: attr)
    }
}

extension FileManager: FileManagerProtocol {}

enum StorageError: Error {
    case directoryNotFound(String)
    case couldNotWriteFile(String)
    case fileNotFound(String)
    case emptyFile(String)
    case couldNotReadFile(String)
    case couldNotDeleteFile(String)
}

protocol CodableStorageProtocol {
    func store<T: Storable & Encodable>(_ object: T, as fileName: String, to directory: FileManager.SearchPathDirectory?) throws
    func retrieve<T: Storable & Decodable>(_ fileName: String, as type: T.Type, from directory: FileManager.SearchPathDirectory?) throws -> T?
    func remove(_ fileName: String, from directory: FileManager.SearchPathDirectory) throws
}

extension CodableStorageProtocol {
    func store<T: Storable & Encodable>(_ object: T, as fileName: String, to directory: FileManager.SearchPathDirectory? = nil) throws {
        return try store(object, as: fileName, to: directory)
    }
    
    func retrieve<T: Storable & Decodable>(_ fileName: String, as type: T.Type, from directory: FileManager.SearchPathDirectory? = nil) throws -> T? {
        return try retrieve(fileName, as: type, from: directory)
    }
}

class CodableStorage: CodableStorageProtocol {
    static let `default` = CodableStorage()
    
    private var fileManager: FileManagerProtocol
    
    init(fileManager: FileManagerProtocol = FileManager.default) {
        self.fileManager = fileManager
    }
    
    func store<T: Storable & Encodable>(_ object: T, as fileName: String, to directory: FileManager.SearchPathDirectory? = nil) throws {
        let destination = directory ?? T.defaultDirectory
        guard let url = fileManager.urls(for: destination, in: .allDomainsMask).first else {
            throw StorageError.directoryNotFound("Could not find directory: \(destination)")
        }
        
        do {
            let data = try JSONEncoder().encode(object)
            let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
            if fileManager.fileExists(atPath: fileUrl.path) {
                try fileManager.removeItem(at: fileUrl)
            }
            fileManager.createFile(atPath: fileUrl.path, contents: data)
        } catch {
            throw StorageError.couldNotWriteFile("Could not write file at \(url.path)")
        }
    }
    
    func retrieve<T: Storable & Decodable>(_ fileName: String, as type: T.Type, from directory: FileManager.SearchPathDirectory? = nil) throws -> T? {
        let destination = directory ?? T.defaultDirectory
        guard let url = fileManager.urls(for: destination, in: .allDomainsMask).first else {
            throw StorageError.directoryNotFound("Could not find directory: \(destination)")
        }
        
        let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
        if !fileManager.fileExists(atPath: fileUrl.path) {
            return nil
        }
        
        if let data = fileManager.contents(atPath: fileUrl.path) {
            do {
                if let expirable = T.self as? Expirable.Type,
                   let attributes = try? fileManager.attributesOfItem(atPath: fileUrl.path),
                   let lastModifiedDate = attributes[FileAttributeKey.modificationDate] as? Date,
                   lastModifiedDate.addingTimeInterval(expirable.timeToLive) < Date() {
                    try fileManager.removeItem(at: fileUrl)
                    return nil
                }
                return try JSONDecoder().decode(type, from: data)
            } catch {
                throw StorageError.couldNotReadFile("Could not read file at \(fileUrl.path)")
            }
        } else {
            return nil
        }
    }
    
    func remove(_ fileName: String, from directory: FileManager.SearchPathDirectory) throws {
        guard let url = fileManager.urls(for: directory, in: .allDomainsMask).first else {
            throw StorageError.directoryNotFound("Could not find directory: \(directory)")
        }
        
        let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
        if fileManager.fileExists(atPath: fileUrl.path) {
            do {
                try fileManager.removeItem(at: fileUrl)
            } catch {
                throw StorageError.couldNotDeleteFile("Could not delete file at \(fileUrl.path)")
            }
        }
    }
}
