//
//  SRSSeparator.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSSeparator: SRSItem {

    override init?(json: Any?) {
        guard let json = json as? [String : Any] else {
            return nil
        }
        super.init(json: json)
    }
}
