//
//  UseCasePreviewAPI.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

struct Intent {
    let code: String
    let description: String
    let fileName: String?
}

enum DemoComponentType: String {
    case message = "Message"
    case view = "View"
    case card = "Card"
    
    static func fromFileName(_ name: String) -> DemoComponentType {
        if name.lowercased().contains("message") {
            return message
        }
        if name.lowercased().contains("view") {
            return view
        } else if name.lowercased().contains("card") {
            return card
        }
        return message
    }
    
    static func prettifyFileName(_ name: String?) -> String? {
        return name?
            .replacingOccurrences(of: "_view_", with: " ")
            .replacingOccurrences(of: "_card_", with: " ")
            .replacingOccurrences(of: "_message_", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

// MARK: - UseCasePreviewAPI

class UseCasePreviewAPI: NSObject {
    
    // MARK: Treewalk Intents
    
    typealias TreewalkIntentsCompletionHandler = ([Intent]?, String?) -> Void
    
    class func getTreewalkIntents(completion: @escaping TreewalkIntentsCompletionHandler) {
        sendGETRequest(path: "/treewalk/intents") { (data, _, statusCode, error) in
            if error != nil || statusCode != 200 {
                Dispatcher.performOnMainThread {
                    completion(nil, error?.localizedDescription ?? "Non-200 status code: \(statusCode)")
                }
                return
            }
            
            var intents: [Intent]?
            var errorString: String?
            if let json = getJSON(from: data), let intentsJSON = json["intents"] as? [[String: Any]] {
                intents = [Intent]()
                for intentJSON in intentsJSON {
                    if let intentCode = intentJSON["Classifications"] as? String,
                        let intentDescription = intentJSON["DEBUG_Display"] as? String {
                        
                        intents?.append(Intent(code: intentCode,
                                               description: intentDescription,
                                               fileName: intentJSON["File"] as? String))
                    }
                }
            } else {
                errorString = "Unable to parse json response"
            }
            
            Dispatcher.performOnMainThread {
                completion(intents, errorString)
            }
        }
        
    }
    
    // MARK: Treewalk
    
    typealias TreewalkCompletionHandler = (ChatMessage?, ComponentViewContainer?, String?) -> Void
    
    class func getTreewalk(with classification: String, completion: @escaping TreewalkCompletionHandler) {
        
        var params = [
            "q": classification,
            "auth": "x"
        ]
        if let context = JSONUtil.stringify(["accountId": "2313"]) {
            params["context"] = context
        }
        
        sendGETRequest(host: "http://localhost:9000",
                       path: "/treewalk",
                       params: params) { (data, _, statusCode, error) in
                        if error != nil || statusCode != 200 {
                            Dispatcher.performOnMainThread {
                                completion(nil, nil, error?.localizedDescription ?? "Non-200 status code: \(statusCode)")
                            }
                            return
                        }
                        
                        var chatMessage: ChatMessage?
                        var viewContainer: ComponentViewContainer?
                        var errorString: String?
                        if let json = getJSON(from: data) {
                            let metadata = EventMetadata(
                                isReply: true,
                                isAutomatedMessage: true,
                                eventId: Int(Date().timeIntervalSince1970),
                                eventType: .srsResponse,
                                issueId: 1,
                                sendTime: Date())
                            chatMessage = ChatMessage.fromJSON(json, with: metadata)
                            viewContainer = ComponentViewContainer.from(json)
                        } else {
                            errorString = "Unable to parse json response"
                        }
                        
                        Dispatcher.performOnMainThread {
                            completion(chatMessage, viewContainer, errorString)
                        }
        }
    }
}

// MARK- Request Utilities

extension UseCasePreviewAPI {
    
    // MARK: Making a Params Object
    
    private class func makeQueryItems(from params: [String: String]) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        for (name, value) in params {
            queryItems.append(URLQueryItem(name: name, value: value))
        }
        return queryItems
    }
    
    // MARK: Creating a Request
    
    private static let HOST = "http://localhost:9000"
    
    private class func makeGETRequest(host: String? = nil, path: String, params: [String: String]? = nil) -> URLRequest {
        
        let apiHost = host ?? HOST
        var urlComponents = URLComponents(string: "\(apiHost)\(path)")
        if let params = params {
            urlComponents?.queryItems = makeQueryItems(from: params)
        }
        
        var request = URLRequest(url: urlComponents!.url!)
        request.httpMethod = "GET"
        
        return request
    }
    
    // MARK: Sending a Request
    
    typealias RequestCompletion = (Data?, URLResponse?, Int, Error?) -> Void
    
    private class func sendGETRequest(host: String? = nil,
                                      path: String,
                                      params: [String: String]? = nil,
                                      completion: @escaping RequestCompletion) {
        
        let request = makeGETRequest(host: host, path: path, params: params)
        
        logRequest(request: request)
        
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            logResponse(response: response, data: data, error: error, request: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            completion(data, response, statusCode, error)
        }).resume()
    }
    
    // MARK: Parsing a response
    
    private class func getJSON(from data: Data?) -> [String: Any]? {
        guard let data = data else {
            return nil
        }
        
        var json: [String: Any]?
        do {
            try json = JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {}
        
        return json
    }
    
    private class func getJSONArray(from data: Data?) -> [Any]? {
        guard let data = data else {
            return nil
        }
        
        var json: [Any]?
        do {
            try json = JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any]
        } catch {}
        
        return json
    }
    
    // MARK: Request Logging
    
    private class func logRequest(request: URLRequest) {
        DebugLog.d("\nSending Get Request: \(request.url?.absoluteString ?? "Ooops")")
    }
    
    private class func logResponse(response: URLResponse?, data: Data?, error: Error?, request: URLRequest) {
        
        var code: Int?
        if let response = response as? HTTPURLResponse {
            code = response.statusCode
        }
        
        var lastLine: String?
        if getJSON(from: data) != nil {
            lastLine = "Body: JSON Object"
        } else if getJSONArray(from: data) != nil {
            lastLine = "Body: JSON Array"
        } else if let error = error {
            lastLine = "Error: \(error.localizedDescription)"
        }
        
        DebugLog.d(
            "\nRequest: \(request.url?.absoluteString ?? "--")\n" +
                "  Returned with: \(code ?? -1)\n" +
            "    \(lastLine ?? "")"
        )
    }
}
