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
    
    // MARK: - Parsing
    
    static func jsonIsLikelyLegacy(_ json: Any?) -> Bool {
        guard let json = json as? [String: Any] else {
            return false
        }
        
        let jsonKeys = json.keys
        return jsonKeys.contains("content")
            && jsonKeys.contains("displayContent")
    }
 
    static func fromLegacySRSJSON(_ json: Any?, with metadata: EventMetadata) -> ChatMessage? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        guard json.string(for: "contentType") != "carousel" else {
            DebugLog.d(caller: self, "fromLegacySRSJSON Failed: Carousels are not supported!")
            return nil
        }
        
        let content = json.jsonObject(for: "content")
        let displayContent = json.bool(for: "displayContent") ?? false
        
        let legacyComponents = extractLegacyComponents(content, metadata: metadata)
        guard legacyComponents.message != nil || legacyComponents.bodyItems != nil else {
            DebugLog.d(caller: self, "fromLegacySRSJSON Failed: Missing message and bodyItems")
            return nil
        }
        
        var quickReplies: [QuickReply]?
        if let buttons = legacyComponents.buttons {
            quickReplies = [QuickReply]()
            for button in buttons {
                quickReplies?.append(QuickReply(title: button.title, action: button.action))
            }
        }
        
        var attachment: ChatMessageAttachment?
        if displayContent {
            if let stackViewItems = ComponentFactory.convertSRSItems(legacyComponents.bodyItems) {
                var style = ComponentStyle()
                style.alignment = .fill
                style.padding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
                
                if let stackView = StackViewItem(orientation: .vertical,
                                                 items: stackViewItems,
                                                 style: style) {
                    attachment = ChatMessageAttachment(content: stackView)
                }
            }
        }
    
        return ChatMessage(text: legacyComponents.message,
                           notification: nil,
                           attachment: attachment,
                           quickReplies: quickReplies,
                           metadata: metadata)
    }
    
    // MARK: - Private Utility Methods
    
    private struct LegacyComponents {
        let message: String?
        let bodyItems: [SRSItem]?
        let buttons: [SRSButton]?
    }
    
    private static func extractLegacyComponents(_ json: [String: Any]?, metadata: EventMetadata) -> LegacyComponents {
        guard let json = json else {
            return LegacyComponents(message: nil, bodyItems: nil, buttons: nil)
        }
     
        let type = json.string(for: "type") ?? "itemlist"
        let orientation = json.string(for: "orientation") ?? "vertical"
        guard type == "itemlist" && orientation == "vertical" else {
            DebugLog.w(caller: self, "extractLegacyComponents Failed: Unsupported type (\(type)) orientation (\(orientation))")
            return LegacyComponents(message: nil, bodyItems: nil, buttons: nil)
        }
        
        guard let itemsJSONArray = json["value"] as? [[String: Any]], !itemsJSONArray.isEmpty else {
            DebugLog.w(caller: self, "extractLegacyComponents Failed: empty value array")
            return LegacyComponents(message: nil, bodyItems: nil, buttons: nil)
        }
        
        var message: String?
        var bodyItems = [SRSItem]()
        var buttons = [SRSButton]()
        
        for (idx, itemJSON) in itemsJSONArray.enumerated() {
            guard let item = SRSItemFactory.parseItem(itemJSON, metadata: metadata) else {
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
    
        return LegacyComponents(message: message, bodyItems: bodyItems, buttons: buttons)
    }
}
