//
//  SRSAppOpenResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSAppOpenResponse: NSObject, JSONObject {
    var greeting: String?
    var customizedMessage: String?
    var customizedActions: [String]?
    var genericActions: [String]?
    var inputPlaceholder: String?

    // MARK:- JSONObject
    
    static func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else { return nil }

        let response = SRSAppOpenResponse()
        response.greeting = json["greeting"] as? String
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
