//
//  SRSFiller.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSFiller: SRSItem {
    
    override init?(json: Any?, metadata: EventMetadata) {
        guard let json = json as? [String: Any] else {
            return nil
        }
        super.init(json: json, metadata: metadata)
    }
}
