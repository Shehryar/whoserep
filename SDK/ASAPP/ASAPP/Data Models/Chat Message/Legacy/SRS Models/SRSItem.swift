//
//  SRSModel.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum SRSItemType: String {
    case button = "button"
    case filler = "filler"
    case icon = "icon"
    case info = "info"
    case itemList = "itemlist"
    case label = "label"
    case separator = "separator"
    
    static func parse(_ value: Any?) -> SRSItemType? {
        guard let value = value as? String else {
            return nil
        }
        return SRSItemType(rawValue: value)
    }
}

class SRSItem: NSObject {

    let type: SRSItemType
    
    init?(json: Any?) {
        guard let json = json as? [String : Any],
            let type = SRSItemType.parse(json["type"]) else {
                return nil
        }
        self.type = type
        super.init()
    }
}
