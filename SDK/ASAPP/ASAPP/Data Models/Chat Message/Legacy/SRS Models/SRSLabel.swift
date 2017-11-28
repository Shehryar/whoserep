//
//  SRSLabel.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSLabel: SRSItem {

    let text: String
    
    override init?(json: Any?, metadata: EventMetadata) {
        guard let json = json as? [String: Any] else {
            return nil
        }
        guard let text = json.string(for: "label") else {
            return nil
        }
        self.text = text
        super.init(json: json, metadata: metadata)
    }
}
