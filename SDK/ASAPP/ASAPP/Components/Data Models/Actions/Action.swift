//
//  Action.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class Action: NSObject {
    
    // MARK: Properties
    
    enum JSONKey: String {
        case data = "data"
    }

    let data: [String : Any]?
    
    // MARK: Init
    
    required init?(content: Any?) {
        if let content = content as? [String : Any] {
            self.data = content[JSONKey.data.rawValue] as? [String : Any]
        } else {
            self.data = nil
        }
        super.init()
    }
}
