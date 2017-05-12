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
        sendGETRequest(path: "/use_cases") { (data, response, error) in
            var useCases = getJSONArray(from: data) as? [String]
            useCases?.sort()
            Dispatcher.performOnMainThread {
                completion(useCases, error)
            }
        }
    }
    
    typealias JSONFilesCompletion = (_ fileNames: [String]?, _ err: Error?) -> Void
    
    class func getJSONFilesNames(completion: @escaping UseCasesCompletion) {
        sendGETRequest(path: "/json_files") { (data, response, error) in
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
                       params: [URLQueryItem(name: "id", value: fileInfo.fileName)],
                       completion: { (data, response, error) in
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
                       params: [URLQueryItem(name: "id", value: fileInfo.fileName)],
                       completion: { (data, response, error) in
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

// MARK- Request Utilities

extension UseCasePreviewAPI {
    
    // MARK: Creating a Request
    
    fileprivate static let HOST = "http://localhost:9000"
    
    fileprivate class func makeGETRequest(with path: String, params: [URLQueryItem]? = nil) -> URLRequest {
        var urlComponents = URLComponents(string: "\(HOST)\(path)")
        urlComponents?.queryItems = params
        
        var request = URLRequest(url: urlComponents!.url!)
        request.httpMethod = "GET"
        
        return request
    }
    
    // MARK: Sending a Request
    
    typealias RequestCompletion = (Data?, URLResponse?, Error?) -> Void
    
    fileprivate class func sendGETRequest(path: String,
                                          params: [URLQueryItem]? = nil,
                                          completion: @escaping RequestCompletion) {
        
        let request = makeGETRequest(with: path, params: params)
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: completion).resume()
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
}
