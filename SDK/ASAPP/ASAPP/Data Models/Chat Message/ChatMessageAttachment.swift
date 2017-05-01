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
    
    // MARK:- Properties
    
    let type: AttachmentType
    
    let image: ChatMessageImage?
    let template: Component?
    let requiresNoContainer: Bool
    let quickRepliesDictionary: [String : [QuickReply]]?
    
    var quickReplies: [QuickReply]? {
        if let quickRepliesDictionary = quickRepliesDictionary,
            let currentValue = template?.value as? String {
            return quickRepliesDictionary[currentValue]
        }
        return nil
    }
    
    // MARK:- Init
    
    init(content: Any, requiresNoContainer: Bool? = nil, quickRepliesDictionary: [String : [QuickReply]]? = nil) {
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
        self.quickRepliesDictionary = quickRepliesDictionary
        super.init()
    }
}

// MARK:- JSON Parsing

extension ChatMessageAttachment {
    
    enum JSONKey: String {
        case quickReplies = "quickReplies"
    }
    
    class func fromJSON(_ json: Any?) -> ChatMessageAttachment? {
        guard let json = json as? [String : Any] else {
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
        
        guard let payload = json["content"] as? [String : AnyObject] else {
            DebugLog.w(caller: self, "Missing payload.")
            return nil
        }
        
        var quickRepliesDictionary: [String : [QuickReply]]? = [String : [QuickReply]]()
        if let quickRepliesJSONDict = json[JSONKey.quickReplies.rawValue] as? [String : [[String : Any]]] {
            for (pageId, buttonsJSON) in quickRepliesJSONDict {
                var quickReplies = [QuickReply]()
                for buttonJSON in buttonsJSON {
                    if let quickReply = QuickReply.fromJSON(buttonJSON) {
                        quickReplies.append(quickReply)
                    }
                }
                if quickReplies.count > 0 {
                    quickRepliesDictionary?[pageId] = quickReplies
                }
            }
        }
        if (quickRepliesDictionary ?? [String : [QuickReply]]()).isEmpty {
            quickRepliesDictionary = nil
        }

        switch type {
        case .image:
            if let image = ChatMessageImage.fromJSON(payload) {
                return ChatMessageAttachment(content: image)
            }
            break
            
        case .template:
            if let componentViewContainer = ComponentViewContainer.from(payload) {
                return ChatMessageAttachment(content: componentViewContainer.root,
                                             requiresNoContainer: json.bool(for: "requiresNoContainer"),
                                             quickRepliesDictionary: quickRepliesDictionary)
            }
            break
            
        case .none:
            // No-op
            break;
        }
        
        return nil
    }
}


