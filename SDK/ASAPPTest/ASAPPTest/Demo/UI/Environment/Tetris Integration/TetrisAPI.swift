//
//  TetrisAPI.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 11/7/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

extension URLRequest {
    mutating func encodeParameters(_ parameters: [String: String]) {
        let charactersToEncode = ":#[]@!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: charactersToEncode)
        
        func percentEncode(_ string: String) -> String {
            return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        }
        
        let parametersArray = parameters.map {
            "\($0)=\(percentEncode($1))"
        }
        
        httpBody = parametersArray.joined(separator: "&").data(using: .utf8)
    }
}

class TetrisAPI: NSObject {
    @discardableResult
    class func requestAuthToken(userId: String, password: String, environment: TetrisEnvironment, completion: ((_ authToken: String?, _ error: String?) -> Void)?) -> URLSessionDataTask? {
        guard let url = environment.getUrl(path: "/rest/v1/AuthenticationService/authenticate") else {
            print("Unable to create request URL")
            return nil
        }
        
        let basicAuth = "iPhoneAM:ETph0neH0m3".data(using: .utf8)!.base64EncodedString()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: String] = [
            "userIdentifierType": "EMAIL",
            "authToken": password,
            "userIdentifier": userId
        ]
        request.encodeParameters(parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                  let dict = jsonObject as? [String: Any] else {
                demoLog("Unable to fetch Tetris auth token: \(String(describing: response))")
                DispatchQueue.main.async {
                    completion?(nil, nil)
                }
                return
            }
            
            demoLog("Tetris auth token response: \(dict)")
            
            if let responseCode = dict["responseCode"] as? Int,
               responseCode == 0,
               let authDict = dict["data"] as? [String: Any],
               let authToken = authDict["artifactValue"] as? String {
                DispatchQueue.main.async {
                    completion?(authToken, nil)
                }
            } else {
                demoLog("Unable to find Tetris auth token in JSON: \(dict)")
                let error = dict["responseMessage"] as? String ?? "No auth token found"
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        }
        
        task.resume()
        
        return task
    }
}
