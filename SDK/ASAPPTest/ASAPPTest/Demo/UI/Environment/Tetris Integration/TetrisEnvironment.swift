//
//  TetrisEnvironment.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 11/8/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

enum TetrisEnvironment: String {
    case test1 = "Test FN1"
    case test2 = "Test FN2"
    case prod = "Prod"
    
    static let defaultValue = test2
    static let allValues = [test1, test2, prod]
    
    var host: String {
        switch self {
        case .test1: return "https://fn1.services.test.bigpond.com"
        case .test2: return "https://fn2.services.test.bigpond.com"
        case .prod: return "https://services.bigpond.com"
        }
    }
    
    func getUrl(path: String) -> URL? {
        let urlString = host + path
        return URL(string: urlString)
    }
}
