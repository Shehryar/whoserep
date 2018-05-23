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
        case image
        case template = "componentView"
        case carousel
       
        static let all = [
            none, image, template, carousel
        ]
    }
    
    // MARK: - Properties
    
    let type: AttachmentType
    
    let carousel: ChatMessageCarousel?
    let image: ChatMessageImage?
    let template: Component?
    
    // MARK: - Init
    
    init(content: Any) {
        var type = AttachmentType.none
        var image: ChatMessageImage?
        var template: Component?
        var carousel: ChatMessageCarousel?
        
        if let contentAsImage = content as? ChatMessageImage {
            type = .image
            image = contentAsImage
        } else if let contentAsCarousel = content as? ChatMessageCarousel {
            type = .carousel
            carousel = contentAsCarousel
        } else if let contentAsTemplate = content as? Component {
            type = .template
            template = contentAsTemplate
        } else {
            DebugLog.w(caller: ChatMessageAttachment.self, "Unable to identify attachment: \(content)")
        }
        
        self.type = type
        self.image = image
        self.template = template
        self.carousel = carousel
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
        case .carousel:
            if let carousel = ChatMessageCarousel.from(payload) {
                return ChatMessageAttachment(content: carousel)
            }
            
        case .image:
            if let image = ChatMessageImage.from(payload) {
                return ChatMessageAttachment(content: image)
            }
            
        case .template:
            if let componentViewContainer = ComponentViewContainer.from(payload) {
                return ChatMessageAttachment(content: componentViewContainer.root)
            }
            
        case .none:
            // No-op
            break
        }
        
        return nil
    }
}
