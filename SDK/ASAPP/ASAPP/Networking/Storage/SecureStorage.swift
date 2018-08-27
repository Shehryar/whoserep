//
//  SecureStorage.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 7/24/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

protocol SecureStorageProtocol {
    func store(data: Data, as key: String) throws
    func retrieve(_ key: String) throws -> Data
    func store<T: Codable>(_ object: T, as key: String) throws
    func retrieve<T: Codable>(_ key: String, as type: T.Type) throws -> T
    func remove(_ key: String) throws
}

enum SecureStorageError: Error {
    case couldNotEncodeObject(String)
    case couldNotStoreObject(String)
    case couldNotRetrieveObject(String)
    case couldNotDecodeObject(String)
    case couldNotDeleteObject(String)
    
    var localizedDescription: String {
        switch self {
        case .couldNotEncodeObject(let message):
            return message
        case .couldNotStoreObject(let message):
            return message
        case .couldNotRetrieveObject(let message):
            return message
        case .couldNotDecodeObject(let message):
            return message
        case .couldNotDeleteObject(let message):
            return message
        }
    }
    
    var errorDescription: String? { return localizedDescription }
}

class SecureStorage: SecureStorageProtocol {
    typealias Query = [CFString: Any]
    
    static let `default` = SecureStorage()
    
    func store(data: Data, as key: String) throws {
        var query = getBaseQuery(for: key)
        query[kSecValueData] = data
        
        var status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            status = SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary)
        }
        
        guard status == noErr else {
            throw SecureStorageError.couldNotStoreObject("Failed to securely store object for key \(key)")
        }
    }
    
    func retrieve(_ key: String) throws -> Data {
        var query = getBaseQuery(for: key)
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnData] = kCFBooleanTrue
        
        var result: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard
            status == noErr,
            let data = result as? Data
        else {
            throw SecureStorageError.couldNotRetrieveObject("Failed to retrieve an object for key \(key)")
        }
        
        return data
    }
    
    func store<T: Codable>(_ object: T, as key: String) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(object)
        } catch {
            throw SecureStorageError.couldNotEncodeObject("Failed to encode object when trying to store it securely for key \(key)")
        }
        
        try store(data: data, as: key)
    }
    
    func retrieve<T: Codable>(_ key: String, as type: T.Type) throws -> T {
        do {
            let data = try retrieve(key)
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw error
        }
    }
    
    func remove(_ key: String) throws {
        let query = getBaseQuery(for: key)
        
        guard SecItemDelete(query as CFDictionary) != noErr else {
            throw SecureStorageError.couldNotDeleteObject("Failed to delete object for key \(key)")
        }
    }
    
    private func getBaseQuery(for key: String) -> Query {
        return [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
            kSecAttrAccount: key,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked
        ]
    }
}