//
//  IncomingMessageDeserializer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum MessageType: String {
    case response = "Response"
    case event = "Event"
    case responseError = "ResponseError"
}

class IncomingMessage {
    var requestId: Int?
    var type: MessageType?
    var bodyString: String?
    var body: [String: Any]?
    var debugError: String?
    var fullMessage: Any?
    
    init(withFullMessage fullMessage: Any? = nil) {
        self.fullMessage = fullMessage
    }
    
    class func errorMessage(_ text: String) -> IncomingMessage {
        let message = IncomingMessage(withFullMessage: text)
        message.type = .responseError
        return message
    }
}

typealias ResponseTimeInMilliseconds = Int

typealias IncomingMessageHandler = ((_ message: IncomingMessage, _ request: SocketRequest?, _ responseTime: ResponseTimeInMilliseconds) -> Void)

typealias RequestResponseHandler = ((_ message: IncomingMessage) -> Void)

class IncomingMessageDeserializer {
    
    func deserialize(_ messageString: String) -> IncomingMessage {
        let serializedMessage = IncomingMessage(withFullMessage: messageString)
        
        let tokens = messageString.split(separator: "|").map(String.init)
        
        serializedMessage.type = MessageType(rawValue: tokens[0])
        if let type = serializedMessage.type {
            switch type {
            case .response:
                serializedMessage.requestId = Int(tokens[1])
                serializedMessage.bodyString = tokens[2...(tokens.count-1)].joined(separator: "|")
                
            case .event:
                serializedMessage.bodyString = tokens[1...(tokens.count-1)].joined(separator: "|")
                
            case .responseError:
                serializedMessage.requestId = Int(tokens[1])
                serializedMessage.bodyString = tokens[2...(tokens.count-1)].joined(separator: "|")
                serializedMessage.debugError = serializedMessage.bodyString
            }
        }
        
        if let bodyString = serializedMessage.bodyString {
            do {
                serializedMessage.body = try JSONSerialization.jsonObject(with: bodyString.data(using: String.Encoding.utf8)!, options: []) as? [String: Any]
            } catch {}
        }

        return serializedMessage
    }
}
