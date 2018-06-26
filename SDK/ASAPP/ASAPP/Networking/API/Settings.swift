//
//  Settings.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 6/21/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

struct Settings: Decodable {
    let redactionRules: [Censor.Rule]
    
    enum CodingKeys: String, CodingKey {
        case redactionRules = "RedactionRules"
    }
}
