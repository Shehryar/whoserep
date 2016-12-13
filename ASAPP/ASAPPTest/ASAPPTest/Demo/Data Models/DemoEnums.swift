//
//  DemoEnums.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/4/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

// MARK:- Company

enum Company: String {
    case asapp = "asapp"
    case asapp2 = "asapp2"
    case comcast = "comcast"
    case sprint = "sprint"
    case mitch = "mitch"
    
    static let all = [
        asapp,
        mitch,
        asapp2,
        comcast,
        sprint,
    ]
}

func CompanyAfter(company: Company) -> Company {
    let allCompanies = Company.all
    var nextCompany: Company = allCompanies[0]
    if let index = allCompanies.index(of: company) {
        if index + 1 >= allCompanies.count {
            nextCompany = allCompanies[0]
        } else {
            nextCompany = allCompanies[index + 1]
        }
    }
    return nextCompany
}

// MARK:- DemoEnvironmentPrefix

enum EnvironmentPrefix: String {
    case sprint = "sprint"
    case comcastStaging = "comcast.preprod"
    case comcastStaging2 = "comcast-api.preprod"
    case comcastProd = "comcast"
    case comcastProd2 = "comcast-api"
    case comcastDemo = "comcast-demo"
    case asappDemo = "demo"
    case asappDemo2 = "demo2"
    case mitch = "mitch"
    case unknown = "unknown"
}

// MARK:- ASAPPEnvironment

func ASAPPEnvironmentForEnvironmentPrefix(_ prefix: EnvironmentPrefix) -> ASAPPEnvironment {
    switch prefix {
    case .sprint: return .staging
    case .comcastStaging: return .staging
    case .comcastStaging2: return .staging
    case .comcastProd: return .production
    case .comcastProd2: return .production
    case .comcastDemo: return .staging
    case .asappDemo: return .staging
    case .asappDemo2: return .staging
    case .mitch: return .staging
    case .unknown: return .staging
    }
}
