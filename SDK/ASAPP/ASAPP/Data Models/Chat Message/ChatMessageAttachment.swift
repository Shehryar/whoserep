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
        case image = "AttachmentTypeImage"
        case template = "AttachmentTypeTemplate"
        case itemList = "AttachmentTypeItemList"
        case itemCarousel = "AttachmentTypeItemCarousel"
        
        static let all = [
            none, image, template, itemList, itemCarousel
        ]
    }
    
    let type: AttachmentType
    
    let image: ChatMessageImage?
    let template: Component?
    let itemList: SRSItemList?
    let itemCarousel: SRSItemCarousel?

    init(content: AnyObject) {
        var type = AttachmentType.none
        var image: ChatMessageImage? = nil
        var template: Component? = nil
        var itemList: SRSItemList? = nil
        var itemCarousel: SRSItemCarousel? = nil
        
        if let contentAsImage = content as? ChatMessageImage {
            type = .image
            image = contentAsImage
        } else if let contentAsTemplate = content as? Component {
            type = .template
            template = contentAsTemplate
        } else if let contentAsItemList = content as? SRSItemList {
            type = .itemList
            itemList = contentAsItemList
        } else if let contentAsItemCarousel = content as? SRSItemCarousel {
            type = .itemCarousel
            itemCarousel = contentAsItemCarousel
        } else {
            DebugLog.w(caller: ChatMessageAttachment.self, "Unable to identify attachment: \(content)")
        }
        
        self.type = type
        self.image = image
        self.template = template
        self.itemList = itemList
        self.itemCarousel = itemCarousel
        super.init()
    }
}

// MARK:- JSON Parsing

extension ChatMessageAttachment {
    
    class func fromJSON(_ json: [String : AnyObject]?) -> ChatMessageAttachment? {
        guard let json = json else {
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
        
        guard let payload = json["payload"] as? [String : AnyObject] else {
            DebugLog.w(caller: self, "Missing payload.")
            return nil
        }
        
        switch type {
        case .image:
            if let image = ChatMessageImage.fromJSON(payload) {
                return ChatMessageAttachment(content: image)
            }
            break
            
        case .template:
            if let component = ComponentFactory.component(with: payload, styles: nil) {
                return ChatMessageAttachment(content: component as AnyObject)
            }
            break
            
        case .itemList, .itemCarousel, .none:
            // No-op
            break;
        }
        
        return nil
    }
}


