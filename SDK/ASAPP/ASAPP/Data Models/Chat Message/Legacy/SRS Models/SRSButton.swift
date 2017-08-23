//
//  SRSButton.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSButton: SRSItem {
    
    let title: String
    
    let action: Action

    override init?(json: Any?, metadata: EventMetadata) {
        guard let json = json as? [String : Any] else {
            return nil
        }
        guard let title = json.string(for: "label") else {
            DebugLog.d(caller: SRSButton.self, "JSON missing label: \(json)")
            return nil
        }
        guard let action = ActionFactory.legacyAction(with: json, buttonTitle: title, metadata: metadata) else {
            DebugLog.d(caller: SRSButton.self, "Unable to parse action from json: \(json)")
            return nil
        }
        
        self.title = title
        self.action = action
        super.init(json: json, metadata: metadata)
    }
}
