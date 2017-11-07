//
//  SpearAPI.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 8/27/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SpearAPI: NSObject {

    @discardableResult
    class func requestAuthToken(userId: String, pin: String, environment: SpearEnvironment, completion: ((_ authToken: String?, _ error: String?) -> Void)?) -> URLSessionDataTask? {
        
        guard let requestUrl = environment.getUrl(path: "/api/prepaid/authentication/1.0/login") else {
            print("Unable to create request url")
            return nil
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("VZO", forHTTPHeaderField: "applicationid")
        request.addValue("no-cache", forHTTPHeaderField: "cache-control")
        request.addValue("VZOtest", forHTTPHeaderField: "enterprisemessageid")
        request.addValue("2007-10-01T14:20:33", forHTTPHeaderField: "messagedatetimestamp")
        request.addValue("test", forHTTPHeaderField: "messageid")
        request.addValue("59045343-1854-90cf-be08-39a39e89c071", forHTTPHeaderField: "postman-token")
  
        let parameters: [String : Any] = [
            "mdn": userId,
            "pin": pin,
            "scope": "login_auth"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                let jsonDict = json as? [String: Any] {
                
                demoLog("Spear Auth Token Response: \(jsonDict)")
                
                if let authToken = jsonDict["access_token"] as? String {
                    DispatchQueue.main.async {
                        completion?(authToken, nil)
                    }
                } else {
                    demoLog("Unable to find Spear Auth Token in json: \(jsonDict)")
                    
                    var error = jsonDict["description"] as? String
                    if error == nil, let errors = jsonDict["errors"] as? [[String : Any]] {
                        var errorDescriptions = [String]()
                        for errorObject in errors {
                            if let errorDescription = errorObject["description"] as? String {
                                if let errorCode = errorObject["code"] {
                                    errorDescriptions.append("\(errorCode): \(errorDescription)")
                                } else {
                                    errorDescriptions.append(errorDescription)
                                }
                            }
                        }
                        if errorDescriptions.count > 0 {
                            error = errorDescriptions.joined(separator: ", ")
                        }
                    }
                    DispatchQueue.main.async {
                        completion?(nil, error)
                    }
                }
                
            } else {
                demoLog("Unable to fetch Spear Auth Token: \(String(describing: response))")
                DispatchQueue.main.async {
                    completion?(nil, nil)
                }
            }
        })
        task.resume()
        
        return task
    }
}
