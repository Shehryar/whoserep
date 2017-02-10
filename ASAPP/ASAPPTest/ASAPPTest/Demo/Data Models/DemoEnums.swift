//
//  DemoEnums.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

enum SubdomainPreset: String {
    case asapp = "demo"
    case mitch = "mitch"
    case comcast = "comcast.preprod"
    case sprint = "sprint"
    
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
    
    static func defaultCompanyFor(subdomain: String?) -> CompanyPreset {
        if let subdomain = subdomain,
            let subdomainPreset = SubdomainPreset(rawValue: subdomain) {
            switch subdomainPreset {
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
