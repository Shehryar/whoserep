//
//  AppOpenResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class AppOpenResponse: NSObject {
    var greeting: String?
    var customizedMessage: String?
    var customizedActions: [String]?
    var genericActions: [String]?
    var inputPlaceholder: String?

    // MARK: - JSONObject
    
    class func fromJSON(_ json: Any?) -> AppOpenResponse? {
        guard let json = json as? [String: Any] else {
            return nil
        }

        let response = AppOpenResponse()
        response.greeting = json["greeting"] as? String
        response.inputPlaceholder = json["input_placeholder"] as? String
        
        var actions = [String]()
        if let predictions = json["predictions"] as? [[String: AnyObject]] {
            
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
