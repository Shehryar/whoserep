//
//  EventTypingStatus.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class EventTypingStatus: NSObject {

    let isTyping: Bool
    
    // MARK:- Init
    
    init(isTyping: Bool) {
        self.isTyping = isTyping
        super.init()
    }
    
    // MARK:- Parsing
    
    class func fromEventJSON(eventJSON: [String : AnyObject]?) -> EventTypingStatus? {
        guard let eventJSON = eventJSON,
            let isTyping = eventJSON["IsTyping"] as? Bool else {
            return nil
        }
        
        return EventTypingStatus(isTyping: isTyping)
    }
}
