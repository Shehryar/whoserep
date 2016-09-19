//
//  SRSAppOpenResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSAppOpenResponse: NSObject, JSONObject {
    var greeting: String
    var customizedMessage: String?
    var actions: [String]?
    var firstActionIsForCustomizedMessage = false
    
    init(greeting: String?) {
        self.greeting = greeting ?? ASAPPLocalizedString("How can we help?")
        super.init()
    }
    
    // MARK:- JSONObject
    
    static func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else { return nil }

        let response = SRSAppOpenResponse(greeting: json["greeting"] as? String)
        response.customizedMessage = json["prediction_display_text"] as? String
        response.actions = json["actions"] as? [String]
        
        return response
    }
}

// MARK:- Sample Data

extension SRSAppOpenResponse {
    class func sampleResponse() -> SRSAppOpenResponse? {
        if let path = ASAPPBundle.pathForResource("sample_predictive_response", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                if let json = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as? [String : AnyObject] {
                    let sample = SRSAppOpenResponse.instanceWithJSON(json) as? SRSAppOpenResponse
                    sample?.firstActionIsForCustomizedMessage = true
                    return sample
                }
            }
        }
        
        return nil
    }
}
