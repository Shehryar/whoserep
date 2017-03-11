//
//  JSONUtil.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/25/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class JSONUtil: NSObject {

    class func stringify(_ object: AnyObject?, prettyPrinted: Bool = false) -> String? {
        guard let object = object else { return nil }
        
        guard JSONSerialization.isValidJSONObject(object) else {
            DebugLog.e("Dictionary is not valid JSON object: \(object)")
            return ""
        }
        
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        if let json = try? JSONSerialization.data(withJSONObject: object, options: options) {
            if let jsonString = String(data: json, encoding: String.Encoding.utf8) {
                return jsonString
            }
            DebugLog.e("Unable to create string from json: \(json)")
            return ""
        }
        
        DebugLog.e("Unable to serialize dictionary as JSON: \(object)")
        return ""
    }
    
    class func parseString(_ jsonString: String?) -> [String : AnyObject]? {
        guard let jsonString = jsonString else {
            return nil
        }
        guard let jsonStringData = jsonString.data(using: String.Encoding.utf8) else {
            DebugLog.d("Unable to get data from string with utf8 encoding: \(jsonString)")
            return nil
        }
        
        var json: [String : AnyObject]?
        do {
            json =  try JSONSerialization.jsonObject(with: jsonStringData, options: []) as? [String : AnyObject]
        } catch {
            DebugLog.d("Unable to serialize string as json: \(jsonString)")
        }
        return json
    }
}
