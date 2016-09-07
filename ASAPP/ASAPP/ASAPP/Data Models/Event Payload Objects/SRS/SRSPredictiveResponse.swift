//
//  SRSPredictiveResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSPredictiveResponse: NSObject, JSONObject {
    var greeting: String
    var customizedMessage: String?
    var actions: [String]?
    
    init(greeting: String?) {
        self.greeting = greeting ?? ASAPPLocalizedString("How can we help?")
        super.init()
    }
    
    // MARK:- JSONObject
    
    static func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else { return nil }

        let response = SRSPredictiveResponse(greeting: json["greeting"] as? String)
        response.customizedMessage = json["prediction_display_text"] as? String
        response.actions = json["actions"] as? [String]
        
        return response
    }
}

// MARK:- Sample Data

extension SRSPredictiveResponse {
    class func sampleResponse() -> SRSPredictiveResponse? {
        if let path = ASAPPBundle.pathForResource("sample_predictive_response", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                if let json = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as? [String : AnyObject] {
                    return SRSPredictiveResponse.instanceWithJSON(json) as? SRSPredictiveResponse
                }
            }
        }
        
        return nil
    }
}
