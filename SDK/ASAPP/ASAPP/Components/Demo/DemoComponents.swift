//
//  DemoComponents.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum DemoComponent: String {
    case stackView = "demo_stack_view"
}

class DemoComponents: NSObject {
    
    typealias ComponentNamesCompletion = ((_ names: [String]?, _ error: String?) -> Void)
    
    typealias ComponentCompletion = ((_ component: Component?, _ error: String?) -> Void)
    
    // MARK: Public
    
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
    
    // MARK: Private Methods
    
    fileprivate class func getRemoteCompontent(with fileName: String,
                                               completion: @escaping ComponentCompletion) {
        let fullFileName = fileName + ".json"
        var request = URLRequest(url: URL(string: "http://localhost:9000/\(fullFileName)")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                let component = ComponentFactory.component(with: json) {
                completion(component, nil)
                return
            }

            completion(nil, "Unable to GET \(fullFileName) on server.")
            }.resume()
    }
    
    fileprivate class func getLocalComponent(with fileName: String) -> Component? {
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
