//
//  UseCasePreviewAPI.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum DemoComponentFileType {
    case useCase
    case json
}

struct DemoComponentFileInfo {
    let fileName: String
    let fileType: DemoComponentFileType
    var componentType: DemoComponentType {
        return DemoComponentType.fromFileName(fileName)
    }
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
            .replacingOccurrences(of: "_view_" , with: " ")
            .replacingOccurrences(of: "_card_", with: " ")
            .replacingOccurrences(of: "_message_", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}

// MARK:- UseCasePreviewAPI
// MARK: Use Cases

class UseCasePreviewAPI: NSObject {
    
    typealias UseCasesCompletion = (_ useCases: [String]?, _ err: Error?) -> Void
    
    class func getUseCases(completion: @escaping UseCasesCompletion) {
        sendGETRequest(path: "/use_cases") { (data, response, statusCode, error) in
            var useCases = getJSONArray(from: data) as? [String]
            useCases?.sort()
            Dispatcher.performOnMainThread {
                completion(useCases, error)
            }
        }
    }
    
    typealias JSONFilesCompletion = (_ fileNames: [String]?, _ err: Error?) -> Void
    
    class func getJSONFilesNames(completion: @escaping UseCasesCompletion) {
        sendGETRequest(path: "/json_files") { (data, response, statusCode, error) in
            var useCases = getJSONArray(from: data) as? [String]
            useCases?.sort()
            Dispatcher.performOnMainThread {
                completion(useCases, error)
            }
        }
    }
}

// MARK: Chat Message

extension UseCasePreviewAPI {
    
    typealias ChatMessageCompletion = (_ chatMessage: ChatMessage?, _ err: Error?) -> Void
    
    class func getChatMessage(fileInfo: DemoComponentFileInfo, completion: @escaping ChatMessageCompletion) {
        
        let path: String
        switch fileInfo.fileType {
        case .useCase:
            path = "/use_case"
            break
            
        case .json:
            path = "/json_file"
            break
        }

        sendGETRequest(path: path,
                       params: ["id" : fileInfo.fileName],
                       completion: { (data, response, statusCode, error) in
                        var chatMessage: ChatMessage?
                        if let json = getJSON(from: data) {
                            let metadata = EventMetadata(isReply: true,
                                                         isAutomatedMessage: true,
                                                         eventId: Int(Date().timeIntervalSince1970),
                                                         eventType: .srsResponse,
                                                         issueId: 1,
                                                         sendTime: Date())
                            chatMessage = ChatMessage.fromJSON(json, with: metadata)
                        }
                        Dispatcher.performOnMainThread {
                            completion(chatMessage, error)
                        }
        })
    }
}

// MARK: ComponentViewContainer

extension UseCasePreviewAPI {
    
    typealias ComponentViewContainerCompletion = (_ componentViewContainer: ComponentViewContainer?, _ err: Error?) -> Void
    
    class func getComponentViewContainer(fileInfo: DemoComponentFileInfo,
                                         completion: @escaping ComponentViewContainerCompletion)  {
        
        let path: String
        switch fileInfo.fileType {
        case .useCase:
            path = "/use_case"
            break
            
        case .json:
            path = "/json_file"
            break
        }
        
        sendGETRequest(path: path,
                       params: ["id" : fileInfo.fileName],
                       completion: { (data, response, statusCode, error) in
                        var componentViewContainer: ComponentViewContainer?
                        if let json = getJSON(from: data) {
                            componentViewContainer = ComponentViewContainer.from(json)
                        }
                        Dispatcher.performOnMainThread {
                            completion(componentViewContainer, error)
                        }
        })
    }
}

// MARK:- Treewalk

extension UseCasePreviewAPI {
    
    typealias TreewalkCompletionHandler = (ChatMessage?, ComponentViewContainer?, String?) -> Void
    
    class func getTreewalk(with classification: String, completion: @escaping TreewalkCompletionHandler) {
        
        var params = [
            "q": classification,
            "auth": "x"
        ]
        if let context = JSONUtil.stringify(["accountId": "2313"]) {
            params["context"] = context
        }
        
        sendGETRequest(host: "http://localhost:7000",
                       path: "/treewalk",
                       params: params) { (data, response, statusCode, error) in
                        if let error = error {
                            Dispatcher.performOnMainThread {
                                completion(nil, nil, error.localizedDescription)
                            }
                            return
                        }
                        
                        if statusCode != 200 {
                            Dispatcher.performOnMainThread {
                                completion(nil, nil, "Non-200 status code: \(statusCode)")
                            }
                            return
                        }
                        
                        var chatMessage: ChatMessage?
                        var viewContainer: ComponentViewContainer?
                        var errorString: String?
                        if let json = getJSON(from: data) {
                            let metadata = EventMetadata(isReply: true,
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
    
    fileprivate class func makeQueryItems(from params: [String : String]) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        for (name, value) in params {
            queryItems.append(URLQueryItem(name: name, value: value))
        }
        return queryItems
    }
    
    // MARK: Creating a Request
    
    fileprivate static let HOST = "http://localhost:9000"
    
    fileprivate class func makeGETRequest(host: String? = nil, path: String, params: [String : String]? = nil) -> URLRequest {
        
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
    
    fileprivate class func sendGETRequest(host: String? = nil,
                                          path: String,
                                          params: [String : String]? = nil,
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
    
    fileprivate class func getJSON(from data: Data?) -> [String: Any]? {
        guard let data = data else {
            return nil
        }
        
        var json: [String : Any]?
        do {
            try json = JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
        } catch {}
        
        return json
    }
    
    fileprivate class func getJSONArray(from data: Data?) -> [Any]? {
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
    
    fileprivate class func logRequest(request: URLRequest) {
        DebugLog.d("\nSending Get Request: \(request.url?.absoluteString ?? "Ooops")")
    }
    
    fileprivate class func logResponse(response: URLResponse?, data: Data?, error: Error?, request: URLRequest) {
        
        var code: Int?
        if let response = response as? HTTPURLResponse {
            code = response.statusCode
        }
        
        var lastLine: String?
        if let _ = getJSON(from: data) {
            lastLine = "Body: JSON Object"
//            lastLine = String(describing: jsonObject)
        } else if let _ = getJSONArray(from: data) {
            lastLine = "Body: JSON Array"
//            lastLine = String(describing: jsonArray)
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
