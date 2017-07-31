//
//  ChatMessage+LegacySRS.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension ChatMessage {
    
    // MARK: ContentType
    
    enum ContentType {
        case itemList
        case unsupported
        
        static func parse(_ value: Any?) -> ContentType {
            guard let value = value as? String else {
                // Default is itemList
                return .itemList
            }
            switch value {
            case "carousel": return .unsupported
            default: return .itemList
            }
        }
    }
    
    // MARK:- Parsing
    
    static func jsonIsLikelyLegacy(_ json: Any?) -> Bool {
        guard let json = json as? [String : Any] else {
            return false
        }
        
        let jsonKeys = json.keys
        return jsonKeys.contains("content")
            && jsonKeys.contains("displayContent")
            && jsonKeys.contains("classification")
    }
 
    static func fromLegacySRSJSON(_ json: Any?, with metadata: EventMetadata) -> ChatMessage? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        guard json.string(for: "contentType") != "carousel" else {
            DebugLog.d(caller: self, "fromLegacySRSJSON Failed: Carousels are not supported!")
            return nil
        }
        
        let classification = json.string(for: "classification")
        let content = json.jsonObject(for: "content")
        let displayContent = json.bool(for: "displayContent") ?? false
        let parentEventLogSeq = json.int(for: "parentEventLogSeq")
        
        let (message, bodyItems, buttons) = extractLegacyComponents(content)
        guard message != nil || bodyItems != nil else {
            DebugLog.d(caller: self, "fromLegacySRSJSON Failed: Missing message and bodyItems")
            return nil
        }
        
        var quickReplies: [QuickReply]?
        if let buttons = buttons {
            quickReplies = [QuickReply]()
            for button in buttons {
                quickReplies?.append(QuickReply(title: button.title, action: button.action))
            }
        }
        
        var attachment: ChatMessageAttachment?
        if displayContent {
            if let stackViewItems = ComponentFactory.convertSRSItems(bodyItems) {
                var style = ComponentStyle()
                style.padding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
                
                if let stackView = StackViewItem(orientation: .vertical,
                                                 items: stackViewItems,
                                                 style: style) {
                    attachment = ChatMessageAttachment(content: stackView)
                }
            }
        }
        
        var quickRepliesHash: [String : [QuickReply]]?
        if let quickReplies = quickReplies, !quickReplies.isEmpty {
            quickRepliesHash = [
                "default" : quickReplies
                ]
        }
    
        return ChatMessage(text: message,
                           attachment: attachment,
                           quickReplies: quickRepliesHash,
                           metadata: metadata)
    }
    
    // MARK:- Private Utility Methods
    
    /// Returns (message, body elements, buttons)
    private static func extractLegacyComponents(_ json: [String : Any]?) -> (String?, [SRSItem]?, [SRSButton]?) {
        guard let json = json else {
            return (nil, nil, nil)
        }
     
        let type = json.string(for: "type")
        let orientation = json.string(for: "orientation")
        guard type == "itemlist" && orientation == "vertical" else {
            DebugLog.w(caller: self, "extractLegacyComponents Failed: Unsupported type (\(type ?? "nil")) orientation (\(orientation ?? "nil"))")
            return (nil, nil, nil)
        }
        
        guard let itemsJSONArray = json["value"] as? [[String : Any]], !itemsJSONArray.isEmpty else {
            DebugLog.w(caller: self, "extractLegacyComponents Failed: empty value array")
            return (nil, nil, nil)
        }
        
        var message: String?
        var bodyItems = [SRSItem]()
        var buttons = [SRSButton]()
        
        for (idx, itemJSON) in itemsJSONArray.enumerated() {
            guard let item = SRSItemFactory.parseItem(itemJSON) else {
                DebugLog.d(caller: self, "Unable to parse item from json: \(itemJSON)")
                continue
            }
            
            if idx == 0, let messageLabel = item as? SRSLabel {
                message = messageLabel.text
            } else if let button = item as? SRSButton {
                buttons.append(button)
            } else {
                bodyItems.append(item)
            }
        }
    
        return (message, bodyItems, buttons)
    }
}
