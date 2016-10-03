//
//  IncomingMessageSerializer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum MessageType: String {
    case Response = "Response"
    case Event = "Event"
    case ResponseError = "ResponseError"
}

class IncomingMessage {
    var requestId: Int?
    var type: MessageType?
    var bodyString: String?
    var body: [String: AnyObject]?
    var debugError: String?
    var fullMessage: Any?
    
    init(withFullMessage fullMessage: Any? = nil) {
        self.fullMessage = fullMessage
    }
}

typealias IncomingMessageHandler = ((IncomingMessage) -> Void)

class IncomingMessageSerializer {
    
    func serializedMessage(_ message: Any?) -> (IncomingMessage) {
        let serializedMessage = IncomingMessage(withFullMessage: message)
        
        guard let messageString = message as? String else {
            serializedMessage.debugError = "Response not in expected string format"
            DebugLogError(serializedMessage.debugError!)
            return serializedMessage
        }
        
        let tokens = messageString.characters.split(separator: "|").map(String.init)
        
        serializedMessage.type = MessageType(rawValue: tokens[0])
        if let type = serializedMessage.type {
            switch type {
            case .Response:
                serializedMessage.requestId = Int(tokens[1])
                serializedMessage.bodyString = tokens[2]
                break
                
            case .Event:
                serializedMessage.bodyString = tokens[1]
                break
                
            case .ResponseError:
                serializedMessage.requestId = Int(tokens[1])
                serializedMessage.bodyString = tokens[2]
                serializedMessage.debugError = serializedMessage.bodyString
                break
            }
        }
        
        if let bodyString = serializedMessage.bodyString {
            do {
                serializedMessage.body = try JSONSerialization.jsonObject(with: bodyString.data(using: String.Encoding.utf8)!, options: []) as? [String: AnyObject]
            } catch {}
        }

        return serializedMessage
    }
}
