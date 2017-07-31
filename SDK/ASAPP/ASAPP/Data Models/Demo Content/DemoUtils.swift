//
//  DemoUtils.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class DemoUtils: NSObject {
    
    // MARK:- File Paths
    
    class func createFilePath(for fileName: String, type: String = "json") -> String? {
        return ASAPP.bundle.path(forResource: fileName, ofType: type)
    }
    
    // MARK:- Reading from File
    
    class func jsonStringForFile(_ fileName: String) -> String? {
        if let path = createFilePath(for: fileName) {
            let contents = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            return contents
        }
        return nil
       
    }
    
    class func jsonDataForFile(_ fileName: String, company: String? = nil) -> Data? {
        if let path = createFilePath(for: fileName) {
            let contents = try? Data(contentsOf: URL(fileURLWithPath: path))
            return contents
        }
        return nil
    }
    
    // MARK:- JSON Serialization
    
    class func jsonObjectForFile(_ fileName: String, company: String? = nil) -> [String : AnyObject]? {
        guard let jsonData = jsonDataForFile(fileName, company: company) else {
            return nil
        }
        
        if let json = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : AnyObject] {
            return json
        }
        return nil
    }
    
    class func jsonObjectAsStringForFile(_ fileName: String, company: String? = nil) -> String? {
        guard let jsonObject = jsonObjectForFile(fileName, company: company) else {
            return nil
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return nil
    }
}
