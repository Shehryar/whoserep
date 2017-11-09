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

enum StorageError: Error {
    case directoryNotFound(String)
    case couldNotWriteFile(String)
    case fileNotFound(String)
    case emptyFile(String)
    case couldNotReadFile(String)
    case couldNotDeleteFile(String)
}

class CodableStorage {
    fileprivate init() {}
    
    static func store<T: Storable & Encodable>(_ object: T, as fileName: String, to directory: FileManager.SearchPathDirectory? = nil) throws {
        let destination = directory ?? T.defaultDirectory
        guard let url = FileManager.default.urls(for: destination, in: .allDomainsMask).first else {
            throw StorageError.directoryNotFound("Could not find directory: \(destination)")
        }
        
        do {
            let data = try JSONEncoder().encode(object)
            let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                try FileManager.default.removeItem(at: fileUrl)
            }
            FileManager.default.createFile(atPath: fileUrl.path, contents: data, attributes: nil)
        } catch {
            throw StorageError.couldNotWriteFile("Could not write file at \(url.path)")
        }
    }
    
    static func retrieve<T: Storable & Decodable>(_ fileName: String, as type: T.Type, from directory: FileManager.SearchPathDirectory? = nil) throws -> T? {
        let destination = directory ?? T.defaultDirectory
        guard let url = FileManager.default.urls(for: destination, in: .allDomainsMask).first else {
            throw StorageError.directoryNotFound("Could not find directory: \(destination)")
        }
        
        let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            return nil
        }
        
        if let data = FileManager.default.contents(atPath: fileUrl.path) {
            do {
                if let expirable = T.self as? Expirable.Type,
                   let attributes = try? FileManager.default.attributesOfItem(atPath: fileUrl.path),
                   let lastModifiedDate = attributes[FileAttributeKey.modificationDate] as? Date,
                   lastModifiedDate.addingTimeInterval(expirable.timeToLive) < Date() {
                    try FileManager.default.removeItem(at: fileUrl)
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
    
    static func remove(_ fileName: String, from directory: FileManager.SearchPathDirectory) throws {
        guard let url = FileManager.default.urls(for: directory, in: .allDomainsMask).first else {
            throw StorageError.directoryNotFound("Could not find directory: \(directory)")
        }
        
        let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            do {
                try FileManager.default.removeItem(at: fileUrl)
            } catch {
                throw StorageError.couldNotDeleteFile("Could not delete file at \(fileUrl.path)")
            }
        }
    }
}
