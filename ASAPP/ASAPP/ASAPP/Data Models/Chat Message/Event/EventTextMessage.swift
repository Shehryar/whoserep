//
//  EventTextMessage.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class EventTextMessage: NSObject {

    let text: String
    
    // MARK:- Init
    
    init(text: String) {
        self.text = text
        super.init()
    }
    
    // MARK:- Parsing
    
    class func fromEventJSON(_ eventJSON: [String : AnyObject]?) -> EventTextMessage? {
        guard let text = eventJSON?["Text"] as? String else {
            return nil
        }
        return EventTextMessage(text: text)
    }
}
