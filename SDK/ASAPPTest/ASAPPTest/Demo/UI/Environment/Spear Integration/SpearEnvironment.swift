//
//  SpearEnvironment.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 8/27/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum SpearEnvironment: String {
    case rtb1 = "RTB1"
    case rtb2 = "RTB2"
    case st1 = "ST1"
    
    static let defaultValue = rtb2
    static let allValues = [rtb1, rtb2, st1]
    
    func getHost() -> String {
        switch self {
        case .rtb1: return "https://rtb1-apiservices.boostmobile.com"
        case .rtb2: return "https://rtb2-apiservices.boostmobile.com"
        case .st1: return "https://st1-apiservices.boostmobile.com"
        }
    }
    
    func getUrl(path: String) -> URL? {
        let urlString = getHost() + path
        return URL(string: urlString)
    }
}


