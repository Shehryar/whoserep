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
            DebugLogError("Dictionary is not valid JSON object: \(object)")
            return ""
        }
        
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        if let json = try? JSONSerialization.data(withJSONObject: object, options: options) {
            if let jsonString = String(data: json, encoding: String.Encoding.utf8) {
                return jsonString
            }
            DebugLogError("Unable to create string from json: \(json)")
            return ""
        }
        
        DebugLogError("Unable to serialize dictionary as JSON: \(object)")
        return ""
    }
}
