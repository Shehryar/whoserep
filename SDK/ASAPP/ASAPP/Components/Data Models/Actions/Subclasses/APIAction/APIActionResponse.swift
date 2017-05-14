//
//  APIActionResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

typealias APIActionResponseHandler = (_ response: APIActionResponse?) -> Void

enum APIActionResponseType: String {
    case finish = "finish"
    case refreshView = "refreshView"
    case componentView = "componentView"
    case error = "error"
    
    static func from(_ value: Any?) -> APIActionResponseType? {
        guard let value = value as? String else {
            return nil
        }
        return APIActionResponseType(rawValue: value)
    }
}

class APIActionResponse: NSObject {

    let type: APIActionResponseType
    
    let view: ComponentViewContainer?
    
    let error: APIActionError?
    
    // MARK:- Init
    
    init(type: APIActionResponseType,
         view: ComponentViewContainer? = nil,
         error: APIActionError? = nil) {
        self.type = type
        self.view = view
        self.error = error
        super.init()
    }
}

extension APIActionResponse {
    
    enum JSONKey: String {
        case type = "type"
        case content = "content"
    }
    
    class func fromJSON(_ json: Any?) -> APIActionResponse? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        guard let type = APIActionResponseType.from(json[JSONKey.type.rawValue]) else {
            DebugLog.w(caller: APIActionResponse.self, "Missing type: \(json)")
            return nil
        }
        let content = json[JSONKey.content.rawValue]
        
        var view: ComponentViewContainer?
        var error: APIActionError?
        switch type {
        case .finish:
            // No content
            break
            
        case .refreshView, .componentView:
            view = ComponentViewContainer.from(content)
            break
            
        case .error:
            error = APIActionError.fromJSON(content)
            break
        }
        
        return APIActionResponse(type: type, view: view, error: error)
    }
}
