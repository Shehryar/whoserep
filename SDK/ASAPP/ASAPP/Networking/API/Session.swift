//
//  Session.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

struct Session: Codable {
    static let rawBodyKey = CodingUserInfoKey(rawValue: "rawBodyKey")!
    
    struct SessionInfo: Codable {
        let customer: Customer
        let company: Company
        
        private enum CodingKeys: String, CodingKey {
            case customer = "Customer"
            case company = "Company"
        }
    }
    
    struct Customer: Codable {
        let primaryIdentifier: String?
        let id: UInt64
        let guid: String?
        
        private enum CodingKeys: String, CodingKey {
            case primaryIdentifier = "PrimaryIdentifier"
            case id = "CustomerId"
            case guid = "CustomerGUID"
        }
        
        func matches(id otherId: String?) -> Bool {
            return (otherId == nil && primaryIdentifier == nil) || otherId == primaryIdentifier
        }
    }
    
    struct Company: Codable {
        let id: Int
        
        private enum CodingKeys: String, CodingKey {
            case id = "CompanyId"
        }
    }
    
    private let parsedInfo: SessionInfo
    private let fullInfo: Data
    
    private enum CodingKeys: String, CodingKey {
        case parsedInfo = "SessionInfo"
        case fullInfo = "_SerializedFullInfo"
    }
    
    var fullInfoAsDict: [String: Any] {
        if let dict = try? JSONSerialization.jsonObject(with: fullInfo, options: []) as? [String: Any] {
            return dict ?? [:]
        }
        return [:]
    }
    
    var isAnonymous: Bool {
        return customer.primaryIdentifier?.isEmpty ?? true
    }
    
    var customer: Customer {
        return parsedInfo.customer
    }
    
    var company: Company {
        return parsedInfo.company
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let rawBodyString = decoder.userInfo[Session.rawBodyKey] as? String,
           let rawBodyData = rawBodyString.data(using: .utf8),
           let bodyDict = try? JSONSerialization.jsonObject(with: rawBodyData, options: []) as? [String: Any],
           let fullInfoDict = bodyDict?["SessionInfo"],
           let fullInfoData = try? JSONSerialization.data(withJSONObject: fullInfoDict, options: []) {
            self.fullInfo = fullInfoData
        } else {
            self.fullInfo = try container.decode(Data.self, forKey: CodingKeys.fullInfo)
        }
        
        let parsedInfo = try container.decode(SessionInfo.self, forKey: CodingKeys.parsedInfo)
        
        let company = parsedInfo.company
        
        var primaryIdentifier = parsedInfo.customer.primaryIdentifier
        if primaryIdentifier?.isEmpty ?? false {
            primaryIdentifier = nil
        }
        let customer = Customer(primaryIdentifier: primaryIdentifier, id: parsedInfo.customer.id, guid: parsedInfo.customer.guid)
        
        self.parsedInfo = SessionInfo(customer: customer, company: company)
    }
}

extension Session: Storable {
    static let defaultDirectory = FileManager.SearchPathDirectory.documentDirectory
}

extension Session: Expirable {
    static let timeToLive: TimeInterval = 15 * 60 // 15 minutes in seconds
}
