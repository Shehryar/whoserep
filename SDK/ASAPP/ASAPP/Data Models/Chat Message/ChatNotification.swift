//
//  ChatNotification.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 2/5/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

class ChatNotification {
    let title: String
    let text: String?
    let button: QuickReply?
    let icon: IconItem?
    let showExpanded: Bool
    
    enum JSONKey: String {
        case title
        case text
        case button
        case icon
        case showExpanded
    }
    
    init(title: String, text: String?, button: QuickReply?, icon: IconItem?, showExpanded: Bool = false) {
        self.title = title
        self.text = text
        self.button = button
        self.icon = icon
        self.showExpanded = showExpanded
    }
    
    class func fromDict(_ dict: [String: Any]) -> ChatNotification {
        let title = dict.string(for: JSONKey.title.rawValue) ?? ""
        let text = dict.string(for: JSONKey.text.rawValue)
        
        var button: QuickReply?
        if let buttonDict = dict.jsonObject(for: JSONKey.button.rawValue) {
            button = QuickReply.fromJSON(buttonDict)
        }
        
        var icon: IconItem?
        if let iconDict = dict.jsonObject(for: JSONKey.icon.rawValue),
           let iconName = iconDict.string(for: "name") {
            icon = ComponentFactory.component(with: iconName, styles: nil) as? IconItem
        }
        
        let showExpanded = dict.bool(for: JSONKey.showExpanded.rawValue) ?? false
        
        return ChatNotification(title: title, text: text, button: button, icon: icon, showExpanded: showExpanded)
    }
}
