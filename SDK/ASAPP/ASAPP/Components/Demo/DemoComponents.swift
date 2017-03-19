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

typealias GETDemoComponentCompletion = ((_ component: Component?, _ error: String?) -> Void)

class DemoComponents: NSObject {
 
    class func getComponent(for demoComponent: DemoComponent,
                            completion: @escaping GETDemoComponentCompletion) {
        getRemoteCompontent(demoComponent) { (remoteComponent, error) in
            if let remoteComponent = remoteComponent {
                DebugLog.i(caller: DemoComponents.self, "Fetched remote component from server: \(demoComponent.rawValue)")
                completion(remoteComponent, nil)
                return
            }
            
            if let localComponent = getLocalComponent(for: demoComponent) {
                DebugLog.i(caller: DemoComponents.self, "Fetched local component: \(demoComponent.rawValue)")
                completion(localComponent, nil)
                return
            }
            
            DebugLog.e(caller: DemoComponents.self, "Unable to fetch component: \(demoComponent.rawValue)")
            completion(nil, "Unable to get component: \(demoComponent)")
        }
    }
    
    // MARK: Private Methods
    
    fileprivate class func getRemoteCompontent(_ demoComponent: DemoComponent,
                                               completion: @escaping GETDemoComponentCompletion) {
        let fileName = demoComponent.rawValue + ".json"
        var request = URLRequest(url: URL(string: "http://localhost:9000/\(fileName)")!)
        request.httpMethod = "GET"
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
    
    fileprivate class func getLocalComponent(for demoComponent: DemoComponent) -> Component? {
        guard let json =  DemoUtils.jsonObjectForFile(demoComponent.rawValue) else {
            DebugLog.w(caller: self, "Unable to find json file: \(demoComponent.rawValue)")
            return nil
        }
        
        guard let component = ComponentFactory.component(with: json) else {
            DebugLog.w(caller: self, "Unable to create demo \(demoComponent) json:\n\(json)")
            return nil
        }
        
        return component
    }
}
