//
//  JSONUtil.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/25/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class JSONUtil: NSObject {

    class func stringify(_ object: Any?, prettyPrinted: Bool = false) -> String? {
        guard let object = object,
            JSONSerialization.isValidJSONObject(object) else {
                return nil
        }

        let options = prettyPrinted ?
            JSONSerialization.WritingOptions.prettyPrinted :
            JSONSerialization.WritingOptions(rawValue: 0)
        
        if let json = try? JSONSerialization.data(withJSONObject: object, options: options) {
            if let jsonString = String(data: json, encoding: String.Encoding.utf8) {
                return jsonString
            }
            DebugLog.e("Unable to create string from json: \(json)")
            return nil
        }
        
        DebugLog.e("Unable to serialize dictionary as JSON: \(object)")
        return nil
    }
    
    class func getDataFrom(_ object: Any?) -> Data? {
        guard let object = object else {
            return nil
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            DebugLog.w(caller: self, "Unable to create data from JSON: \(object)")
            return nil
        }
        
        return data
    }
    
    class func getObjectFrom(_ data: Data?) -> Any? {
        guard let data = data else {
            return nil
        }
        
        guard let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            DebugLog.w(caller: self, "Unable to create object from data")
            return nil
        }
        
        return object
    }
}

