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
    var customizedActions: [String]?
    var genericActions: [String]?
    var inputPlaceholder: String?
    
    init(greeting: String?) {
        self.greeting = greeting ?? ASAPPLocalizedString("How can we help?")
        super.init()
    }
    
    // MARK:- JSONObject
    
    static func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else { return nil }

        let response = SRSAppOpenResponse(greeting: json["greeting"] as? String)
        response.inputPlaceholder = json["input_placeholder"] as? String
        
        var actions = [String]()
        if let predictions = json["predictions"] as? [[String : AnyObject]] {
            
            for (idx, predictionJSON) in predictions.enumerated() {
                if idx == 0 {
                    response.customizedMessage = predictionJSON["prediction_display_text"] as? String
                    response.customizedActions = predictionJSON["prediction_actions"] as? [String]
                } else {
                    if let predictionActions = predictionJSON["prediction_actions"] as? [String] {
                        actions.append(contentsOf: predictionActions)
                    }
                }
            }
        }
        if let genericActions = json["actions"] as? [String] {
            actions.append(contentsOf: genericActions)
        }
        response.genericActions = actions
        
        return response
    }
}

// MARK:- Sample Data

extension SRSAppOpenResponse {
    class func sampleResponse() -> SRSAppOpenResponse? {
        if let path = ASAPPBundle.path(forResource: "sample_predictive_response", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                if let json = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : AnyObject] {
                    let sample = SRSAppOpenResponse.instanceWithJSON(json) as? SRSAppOpenResponse
                    return sample
                }
            }
        }
        
        return nil
    }
}
