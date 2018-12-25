//
//  Session.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

struct Session: Codable {
    var fullInfo: Data?
    
    let id: String
    private let _authenticatedTime: UInt?
    let customerPrimaryIdentifier: String?
    let customerId: UInt64
    let customerGuid: String?
    let companyId: Int
    let token: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "session_id"
        case _authenticatedTime = "authenticated_time"
        case customerPrimaryIdentifier = "customer_primary_identifier"
        case customerId = "customer_id"
        case customerGuid = "customer_guid"
        case companyId = "company_id"
        case token = "session_token"
        case fullInfo = "_serializedFullInfo"
    }
    
    var authenticatedTime: Date {
        return Date(timeIntervalSince1970: TimeInterval((_authenticatedTime ?? 0) / 1_000_000))
    }
    
    private var fullInfoAsDict: [String: Any] {
        if let fullInfo = fullInfo,
           let dict = try? JSONSerialization.jsonObject(with: fullInfo, options: []) as? [String: Any] {
            return dict ?? [:]
        }
        return [:]
    }
    
    var isAnonymous: Bool {
        return customerPrimaryIdentifier?.isEmpty ?? true
    }
    
    func customerMatches(primaryId otherId: String?) -> Bool {
        return (otherId == nil && customerPrimaryIdentifier == nil) || otherId == customerPrimaryIdentifier
    }
}

extension Session: Storable {
    static let defaultDirectory = FileManager.SearchPathDirectory.documentDirectory
}

extension Session: Equatable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.fullInfo == rhs.fullInfo
    }
}
