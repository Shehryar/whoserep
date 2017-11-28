//
//  ChatMessageAttachment.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatMessageAttachment: NSObject {

    enum AttachmentType: String {
        case none = "AttachmentTypeNone"
        case image = "image"
        case template = "componentView"
       
        static let all = [
            none, image, template
        ]
    }
    
    // MARK: - Properties
    
    let type: AttachmentType
    
    let image: ChatMessageImage?
    let template: Component?
    let requiresNoContainer: Bool
    
    var currentValue: Any? {
        return template?.value
    }
    
    // MARK: - Init
    
    init(content: Any, requiresNoContainer: Bool? = nil) {
        var type = AttachmentType.none
        var image: ChatMessageImage? = nil
        var template: Component? = nil
        
        if let contentAsImage = content as? ChatMessageImage {
            type = .image
            image = contentAsImage
        } else if let contentAsTemplate = content as? Component {
            type = .template
            template = contentAsTemplate
        } else {
            DebugLog.w(caller: ChatMessageAttachment.self, "Unable to identify attachment: \(content)")
        }
        
        self.type = type
        self.image = image
        self.template = template
        self.requiresNoContainer = requiresNoContainer ?? false
        super.init()
    }
}

// MARK: - JSON Parsing

extension ChatMessageAttachment {
    
    class func fromJSON(_ json: Any?) -> ChatMessageAttachment? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        guard let typeString = json["type"] as? String else {
            DebugLog.w(caller: self, "Missing type in json: \(json)")
            return nil
        }
        guard let type = ChatMessageAttachment.AttachmentType(rawValue: typeString) else {
            DebugLog.w(caller: self, "Unknown attachment type [\(typeString)]: \(json)")
            return nil
        }
        
        guard let payload = json["content"] as? [String: AnyObject] else {
            DebugLog.w(caller: self, "Missing payload.")
            return nil
        }
        
        switch type {
        case .image:
            if let image = ChatMessageImage.fromJSON(payload) {
                return ChatMessageAttachment(content: image)
            }
            
        case .template:
            if let componentViewContainer = ComponentViewContainer.from(payload) {
                return ChatMessageAttachment(
                    content: componentViewContainer.root,
                    requiresNoContainer: json.bool(for: "requiresNoContainer"))
            }
            
        case .none:
            // No-op
            break
        }
        
        return nil
    }
}
