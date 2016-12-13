//
//  SRSButtonItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum SRSButtonItemType: String {
    case Link = "LINK"
    case InAppLink = "_N/A_"
    case SRS = "AID"
    case Action = "ACTION"
    case Message = "MESSAGE"
    case AppAction = "APP_ACTION"
}

enum AppAction: String {
    case Ask = "ask"
    case BeginLiveChat = "live_chat"
}

class SRSButtonItem: NSObject, JSONObject {
    
    // MARK: Required Properties
    
    var title: String
    var type: SRSButtonItemType
    var isAutoSelect = false
    
    // MARK: Link Properties
    
    var deepLink: String?
    var deepLinkData: [String : AnyObject]?

    // MARK: Web URL 
    
    var webURL: URL? {
        if deepLink == "url" {
            if let urlString = deepLinkData?["url"] as? String {
                return URL(string: urlString)
            }
        }
        return nil
    }
    
    // MARK: SRS Properties
    
    var srsValue: String?
    
    // MARK: Message Properties
    
    var message: String?
    
    // MARK: Action Properties
    
    var actionName: String?
    
    // MARK: App Action
    
    var appAction: AppAction?
    
    // MARK:- Init
    
    init(title: String, type: SRSButtonItemType) {
        self.title = title
        self.type = type
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json,
            let title = json["label"] as? String else {
                return nil
        }
        
        guard let valueJSON = json["value"] as? [String : AnyObject],
            let typeString = valueJSON["type"] as? String,
            let type = SRSButtonItemType(rawValue: typeString) else {
                return nil
        }
        
        let button = SRSButtonItem(title: title, type: type)
        if let isAutoSelect = json["isAutoSelect"] as? Bool {
            button.isAutoSelect = isAutoSelect
        }
        
        switch button.type {
        case .InAppLink, .Link:
            if let content = valueJSON["content"] as? [String : AnyObject] {
                button.deepLink = content["deepLink"] as? String
                button.deepLinkData = content["deepLinkData"] as? [String : AnyObject]
            }
            break
            
        case .SRS:
            button.srsValue = valueJSON["content"] as? String
            break
            
        case .Action:
            button.actionName = valueJSON["content"] as? String
            break
            
        case .Message:
            button.message = valueJSON["content"] as? String
            break
            
        case .AppAction:
            button.actionName = valueJSON["content"] as? String
            if let actionName = button.actionName {
                button.appAction = AppAction(rawValue: actionName)
            }
            break
        }
 
        return button
    }
}
