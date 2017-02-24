//
//  DemoEnums.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

enum APIHostNamePreset: String {
    case asapp = "demo.asapp.com"
    case mitch = "mitch.asapp.com"
    case comcast = "comcast.preprod.asapp.com"
    case sprint = "sprint.asapp.com"
    
    static let all = [
        asapp,
        mitch,
        comcast,
        sprint,
        ]
}

enum CompanyPreset: String {
    case asapp = "asapp"
    case mitch = "mitch"
    case comcast = "comcast"
    case sprint = "sprint"
    
    static func defaultCompanyFor(apiHostName: String?) -> CompanyPreset {
        if let apiHostName = apiHostName,
            let apiHostNamePreset = APIHostNamePreset(rawValue: apiHostName) {
            switch apiHostNamePreset {
            case .asapp: return asapp
            case .mitch: return mitch
            case .comcast: return comcast
            case .sprint: return sprint
            }
        }
        return asapp
    }
    
    static let all = [
        asapp,
        mitch,
        comcast,
        sprint
    ]
}

enum BrandingType: String {
    case asapp = "asapp"
    case xfinity = "xfinity"
    case sprint = "sprint"
    case boostMobile = "boostMobile"
    
    static let all = [
        asapp,
        xfinity,
        sprint,
        boostMobile
    ]
}
