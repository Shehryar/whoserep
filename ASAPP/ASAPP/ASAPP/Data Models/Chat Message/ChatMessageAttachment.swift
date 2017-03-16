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
        case image = "image"
        case template = "template"
        case itemList = "item_list"
        case itemCarousel = "item_carousel"
    }
    
    let type: AttachmentType
    let image: ChatMessageImage?
    let component: Component?
    let itemList: SRSItemList?
    let itemCarousel: SRSItemCarousel?
    
    init(image: ChatMessageImage) {
        self.type = .image
        self.image = image
        self.component = nil
        self.itemList = nil
        self.itemCarousel = nil
        super.init()
    }
    
    init(component: Component) {
        self.type = .template
        self.image = nil
        self.component = component
        self.itemList = nil
        self.itemCarousel = nil
        super.init()
    }
    
    init(itemList: SRSItemList) {
        self.type = .itemList
        self.image = nil
        self.component = nil
        self.itemList = itemList
        self.itemCarousel = nil
        super.init()
    }
    
    init(itemCarousel: SRSItemCarousel) {
        self.type = .itemCarousel
        self.image = nil
        self.component = nil
        self.itemList = nil
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
                return ChatMessageAttachment(image: image)
            }
            break
            
        case .template:
            if let component = ComponentFactory.component(with: payload) {
                return ChatMessageAttachment(component: component)
            }
            break
            
        case .itemList, .itemCarousel:
            // No-op
            break;
        }
        
        return nil
    }
}


