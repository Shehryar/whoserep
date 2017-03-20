//
//  DemoComponents.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum DemoComponent: String {
    case stackView = "stack_view"
    case transactionHistory = "transaction_history"
    
    static let allRawValues = [
        stackView.rawValue,
        transactionHistory.rawValue
    ]
}

class DemoComponents: NSObject {
    
    typealias ComponentNamesCompletion = ((_ names: [String]?) -> Void)
    
    typealias ComponentCompletion = ((_ component: Component?, _ error: String?) -> Void)
    
    fileprivate static let HOST = "http://localhost:9000"
    
    fileprivate class func getRequest(with path: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(HOST)\(path)")!)
        request.httpMethod = "GET"
        return request
    }
}

// MARK:- Component Names

extension DemoComponents {
    
    // MARK: Public
    
    class func getComponentNames(completion: @escaping ComponentNamesCompletion) {
        getRemoteComponentNames { (componentNames) in
            if let componentNames = componentNames {
                DebugLog.i(caller: DemoComponents.self, "Fetched remote components: \(componentNames)")
                completion(componentNames)
                return
            }
            DebugLog.i(caller: DemoComponents.self, "Unable to fetch remote components.")
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

// MARK:- Components

extension DemoComponents {
    
    class func getComponent(with fileName: String,
                            completion: @escaping ComponentCompletion) {
        
        getRemoteCompontent(with: fileName) { (remoteComponent, error) in
            if let remoteComponent = remoteComponent {
                DebugLog.i(caller: DemoComponents.self, "Fetched remote component from server: \(fileName)")
                completion(remoteComponent, nil)
                return
            }
            
            if let localComponent = getLocalComponent(with: fileName) {
                DebugLog.i(caller: DemoComponents.self, "Fetched local component: \(fileName)")
                completion(localComponent, nil)
                return
            }
            
            DebugLog.e(caller: DemoComponents.self, "Unable to fetch component: \(fileName)")
            completion(nil, "Unable to get component: \(fileName)")
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
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                let component = ComponentFactory.component(with: json) {
                completion(component, nil)
                return
            }
            
            completion(nil, "Unable to GET \(fileName) on server.")
            }.resume()
    }
    
    private class func getLocalComponent(with fileName: String) -> Component? {
        guard let json =  DemoUtils.jsonObjectForFile(fileName) else {
            DebugLog.w(caller: self, "Unable to find json file: \(fileName)")
            return nil
        }
        
        guard let component = ComponentFactory.component(with: json) else {
            DebugLog.w(caller: self, "Unable to create demo \(fileName) json:\n\(json)")
            return nil
        }
        
        return component
    }
}
