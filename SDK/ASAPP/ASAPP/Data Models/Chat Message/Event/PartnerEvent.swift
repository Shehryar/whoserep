//
//  PartnerEvent.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/26/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

class PartnerEvent {
    let name: String
    let data: [String: Any]?
    
    init(name: String, data: [String: Any]?) {
        self.name = name
        self.data = data
    }
}

extension PartnerEvent {
    enum JSONKey: String {
        case name = "type"
        case data
    }
    
    class func fromDict(_ dict: [String: Any]) -> PartnerEvent? {
        guard let name = dict.string(for: JSONKey.name.rawValue) else {
            DebugLog.w(caller: self, "PartnerEvent missing type")
            return nil
        }
        
        let data = dict.jsonObject(for: JSONKey.data.rawValue)
        
        return PartnerEvent(name: name, data: data)
    }
}
