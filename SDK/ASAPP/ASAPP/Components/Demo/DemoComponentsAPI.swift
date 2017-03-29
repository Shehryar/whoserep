//
//  DemoComponentsAPI.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum DemoComponent: String {
    case textHistoryCard = "text_history_card"

    static let allRawValues = [
        textHistoryCard.rawValue
    ]
}

enum DemoComponentType {
    case message
    case view
    case card
    
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
        return name?.replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "view" , with: "")
            .replacingOccurrences(of: "card", with: "")
            .replacingOccurrences(of: "message", with: "")
            .capitalized
    }
}

class DemoComponentsAPI: NSObject {
    
    typealias ComponentNamesCompletion = ((_ names: [String]?) -> Void)
    
    typealias ComponentCompletion = ((_ component: ComponentViewContainer?, _ json: [String : Any]?, _ error: String?) -> Void)
    
    fileprivate static let HOST = "http://localhost:9000"
    
    fileprivate class func getRequest(with path: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(HOST)\(path)")!)
        request.httpMethod = "GET"
        return request
    }
}

// MARK:- API Action

extension DemoComponentsAPI {
    
    func sendAPIAction(_ action: APIAction, completion: APIActionCompletion) {
        /*
        switch action.requestPath {
        case "saveC":
            <#code#>
        default:
            <#code#>
        }*/
        
        
        
    }
    
    
}

// MARK:- Component Names

extension DemoComponentsAPI {
    
    // MARK: Public
    
    class func getComponentNames(completion: @escaping ComponentNamesCompletion) {
        getRemoteComponentNames { (componentNames) in
            if let componentNames = componentNames {
                DebugLog.i(caller: DemoComponentsAPI.self, "Fetched remote components: \(componentNames)")
                completion(componentNames)
                return
            }
            DebugLog.i(caller: DemoComponentsAPI.self, "Unable to fetch remote components.")
            completion(DemoComponent.allRawValues)
        }
    }
    
    // MARK: Private
    
    private class func getRemoteComponentNames(completion: @escaping ComponentNamesCompletion) {
        let path = "/components"
        var request = getRequest(with: path)
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                let namesArray = json as? [String] {
                completion(namesArray)
            } else {
                completion(nil)
            }
            }.resume()
    }
}

// MARK:- Messages

extension DemoComponentsAPI {
    
    class func getChatMessage(with fileName: String,
                              completion: @escaping ((_ message: ChatMessage?, _ error: Error?) -> Void)) {
        getJSON(with: fileName) { (json, err) in
            guard let json = json else {
                completion(nil, err)
                return
            }
            
            let (text, attachment, quickReplies) = ChatMessage.parseContent(from: json)
            let message = ChatMessage(text: text,
                                      attachment: attachment,
                                      quickReplies: quickReplies,
                                      isReply: true,
                                      sendTime: Date(),
                                      eventId: Int(Date().timeIntervalSince1970),
                                      eventType: .srsResponse,
                                      issueId: 1)
            completion(message, nil)
        }
    }
    
    class func getJSON(with fileName: String, completion: @escaping ((_ json: [String : Any]?, _ err: Error?) -> Void)) {
        let path = "/\(fileName).json"
        let request = getRequest(with: path)
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            var json: [String : Any]?
            if let data = data {
                do {
                    try json = JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
                } catch {}
            }
            completion(json, err)
            }.resume()
    }
}

// MARK:- Components

extension DemoComponentsAPI {
    
    class func getComponents(with names: [String], completion: @escaping (([ComponentViewContainer]) -> Void)) {
        var components = [ComponentViewContainer]()
        // Lazy.... :\  Should probably add this to the server as a separate endpoint
        for (idx, name) in names.enumerated() {
            getComponent(with: name, completion: { (component, json, error) in
                
                if let component = component {
                    components.append(component)
                }
                if name == names.last {
                    completion(components)
                }
            })
        }
    }
    
    class func getComponent(with fileName: String,
                            completion: @escaping ComponentCompletion) {
        
        getRemoteCompontent(with: fileName) { (remoteComponent, json, error) in
            if let remoteComponent = remoteComponent {
                DebugLog.i(caller: DemoComponentsAPI.self, "Fetched remote component from server: \(fileName)")
                completion(remoteComponent, json, nil)
                return
            }
            
            if let (localComponent, localJSON) = getLocalComponent(with: fileName) {
                DebugLog.i(caller: DemoComponentsAPI.self, "Fetched local component: \(fileName)")
                completion(localComponent, localJSON, nil)
                return
            }
            
            DebugLog.e(caller: DemoComponentsAPI.self, "Unable to fetch component: \(fileName)")
            completion(nil, nil, "Unable to get component: \(fileName)")
        }
    }
    
    // MARK: Private
    
    private class func getRemoteCompontent(with fileName: String,
                                               completion: @escaping ComponentCompletion) {
        let path = "/\(fileName).json"
        let request = getRequest(with: path)
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any],
                let component = ComponentViewContainer.from(json) {
                    completion(component, json, nil)
                    return
            }
            
            completion(nil, nil, "Unable to GET \(fileName) on server.")
            }.resume()
    }
    
    private class func getLocalComponent(with fileName: String) -> (ComponentViewContainer, [String : Any])? {
        guard let json =  DemoUtils.jsonObjectForFile(fileName) else {
            DebugLog.w(caller: self, "Unable to find json file: \(fileName)")
            return nil
        }
        
        guard let component = ComponentViewContainer.from(json)  else {
            DebugLog.w(caller: self, "Unable to create demo \(fileName) json:\n\(json)")
            return nil
        }
        
        return (component, json)
    }
}
