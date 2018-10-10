//
//  AuthenticationAPI.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 6/13/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

class AuthenticationAPI: NSObject {
    
    @discardableResult
    class func requestAuthToken(apiHostName: String, appId: String, userId: String, password: String, completion: ((_ customerId: String?, _ authToken: String?, _ error: String?) -> Void)?) -> URLSessionDataTask? {
        
        guard let requestUrl = URL(string: "https://\(apiHostName)/api/noauth/treewalkAuthenticate") else {
            print("Unable to create request url")
            return nil
        }
        
        var request = URLRequest(url: requestUrl)
        request.timeoutInterval = 10
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        let parameters: [String: Any] = [
            "appId": appId,
            "userId": userId,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
               let jsonDict = json as? [String: Any] {
                demoLog("Auth token response: \(jsonDict)")
                
                if let authToken = jsonDict["access_token"] as? String {
                    let customerId = jsonDict["customer_id"] as? String
                    DispatchQueue.main.async {
                        completion?(customerId, authToken, nil)
                    }
                } else {
                    demoLog("Unable to find auth token in JSON: \(jsonDict)")
                    let error = "No access_token found in response."
                    DispatchQueue.main.async {
                        completion?(nil, nil, error)
                    }
                }
            } else {
                demoLog("Unable to fetch auth token: \(String(describing: response))")
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    demoLog(body)
                }
                DispatchQueue.main.async {
                    completion?(nil, nil, nil)
                }
            }
        })
        task.resume()
        
        return task
    }
}
