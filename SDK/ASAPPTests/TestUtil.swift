//
//  TestUtil.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TestUtil: NSObject {
    
    static let bundle = Bundle(for: TestUtil.self)
    
    // MARK:- JSON

    class func jsonForFile(named fileName: String) -> [String : Any]? {
        
        guard let filePath = bundle.path(forResource: fileName, ofType: "json") else {
            log(caller: self, "Unable to generate filePath for file named: \(fileName)")
            return nil
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            log(caller: self, "Unable to parse data from file with path: \(filePath)")
            return nil
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any] else {
            log(caller: self, "Unable to parse JSON from data")
            return nil
        }
        return json
    }
    
    // MARK:- Logging
    
    class func log(caller: Any? = nil, _ message: String) {
        
        let prefix: String
        if let caller = caller {
            prefix = "ASAPPTests [\(String(describing: type(of: caller)))"
        } else {
            prefix = "ASAPPTests"
        }

        print("\(prefix): \(message)")
    }
}
