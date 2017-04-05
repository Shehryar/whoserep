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
    
    class func createFilePaths(fileName: String, company: String?) -> (/* filePath */ String?, /* companyFilePath */ String?) {
        let filePath = ASAPP.bundle.path(forResource: fileName, ofType: "json")
        
        var companyFilePath: String?
        if let company = company {

            let companyFileName: String
            if company == "text-rex" {
                companyFileName = "sprint_\(fileName)"
            } else {
                companyFileName = "\(company)_\(fileName)"
            }
            companyFilePath = ASAPP.bundle.path(forResource: companyFileName, ofType: "json")
        }
        
        return (filePath, companyFilePath)
    }
    
    // MARK:- Reading from File
    
    class func jsonStringForFile(_ fileName: String, company: String? = nil) -> String? {
        var stringOnFile: String?
        
        let (path, companyPath) = createFilePaths(fileName: fileName, company: company)
        
        // Try company path, if available, else fall back to default
        if let companyPath = companyPath {
            stringOnFile = try? String(contentsOfFile: companyPath, encoding: String.Encoding.utf8)
        }
        if stringOnFile == nil {
            if let path = path {
                stringOnFile = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
            }
        }

        return stringOnFile
    }
    
    class func jsonDataForFile(_ fileName: String, company: String? = nil) -> Data? {
        var dataOnFile: Data?
        
        let (path, companyPath) = createFilePaths(fileName: fileName, company: company)
        
        // Try company path, if available, else fall back to default
        if let companyPath = companyPath {
            dataOnFile = try? Data(contentsOf: URL(fileURLWithPath: companyPath))
        }
        if dataOnFile == nil {
            if let path = path {
                dataOnFile = try? Data(contentsOf: URL(fileURLWithPath: path))
            }
        }
        
        return dataOnFile
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
