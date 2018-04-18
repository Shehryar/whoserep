//
//  ChatMessageNotification.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 2/5/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

class ChatMessageNotification {
    let title: String
    let text: String?
    let button: ButtonItem?
    let icon: IconItem?
    let expiration: Date?
    
    enum JSONKey: String {
        case title
        case text
        case button
        case icon
        case expiration
    }
    
    init(title: String, text: String?, button: ButtonItem?, icon: IconItem?, expiration: Date?) {
        self.title = title
        self.text = text
        self.button = button
        self.icon = icon
        self.expiration = expiration
    }
    
    class func fromDict(_ dict: [String: Any]) -> ChatMessageNotification {
        let title = dict.string(for: JSONKey.title.rawValue) ?? ""
        let text = dict.string(for: JSONKey.text.rawValue)
        
        let fakeButtonDict = [
            "type": "button",
            "content": dict.jsonObject(for: JSONKey.button.rawValue) ?? ""
        ] as [String: Any]
        let button = ComponentFactory.component(with: fakeButtonDict, styles: nil) as? ButtonItem
        
        var icon: IconItem?
        if let iconDict = dict.jsonObject(for: JSONKey.icon.rawValue) {
            icon = ComponentFactory.component(with: iconDict.string(for: "name"), styles: nil) as? IconItem
        }
        
        var expiration: Date?
        if let expirationInt = dict.int(for: JSONKey.expiration.rawValue) {
            expiration = Date(timeIntervalSince1970: TimeInterval(expirationInt))
        }
        
        return ChatMessageNotification(title: title, text: text, button: button, icon: icon, expiration: expiration)
    }
}
