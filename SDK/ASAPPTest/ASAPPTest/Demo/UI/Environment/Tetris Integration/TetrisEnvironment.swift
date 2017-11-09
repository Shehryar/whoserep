//
//  TetrisEnvironment.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 11/8/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

enum TetrisEnvironment: String {
    case test = "Test"
    case prod = "Prod"
    
    static let defaultValue = test
    static let allValues = [test, prod]
    
    var host: String {
        switch self {
        case .test: return "https://fn1.services.test.bigpond.com"
        case .prod: return "https://services.bigpond.com"
        }
    }
    
    func getUrl(path: String) -> URL? {
        let urlString = host + path
        return URL(string: urlString)
    }
}
