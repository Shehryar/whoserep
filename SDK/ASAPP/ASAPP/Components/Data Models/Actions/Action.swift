//
//  Action.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class Action: NSObject {

    var type: ActionType {
        fatalError("Subclass must override property -type")
    }
    
    var willExitASAPP: Bool {
        return false
    }
    
    // MARK:- Init
    
    required init?(content: Any?) {
        super.init()
    }
}
