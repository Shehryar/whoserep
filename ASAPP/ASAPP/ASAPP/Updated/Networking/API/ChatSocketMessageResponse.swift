//
//  ChatSocketMessageResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatSocketMessageResponse: NSObject {
    
    enum MessageType: String {
        case Response = "Response"
        case Event = "Event"
        case ResponseError = "ResponseError"
    }
    
    // Properties
    
    var originalMessage: AnyObject?
    var type: MessageType?
    var requestId: Int?
    var body: AnyObject?
    var serializedbody: [String: AnyObject]?
    
    init(withResponse responseObject: AnyObject?) {
        self.originalMessage = responseObject
        if let responseString = responseObject as? String {
            let tokens = responseString.characters.split("|").map(String.init)
            let messageType = tokens[0]
            
            self.type = MessageType(rawValue: tokens[0])
            if let type = self.type {
                switch type {
                case .Response:
                    self.requestId = Int(tokens[1])
                    self.body = tokens[2]
                    break
                    
                case .Event:
                    self.body = tokens[1]
                    break
                
                case .ResponseError:
                    
                    break
                }
            }
        }
        
        if let rawBody = self.body as? String {
            if rawBody != "null" {
                do {
                    self.serializedbody = try NSJSONSerialization.JSONObjectWithData(rawBody.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as? [String: AnyObject]
                } catch {
                    DebugLogError("Unable to serialize reponse: \(rawBody)")
                }
            }
        }
        
        super.init()
    }
    
}
