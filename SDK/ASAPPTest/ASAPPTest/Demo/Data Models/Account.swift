//
//  Account.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 6/12/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

struct Account: Codable {
    let username: String
    let password: String?
}

extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.username == rhs.username &&
               lhs.password == rhs.password
    }
}

extension Account: Hashable {
    var hashValue: Int {
        return username.sdbmHashValue ^ (password?.hashValue ?? 0)
    }
}
