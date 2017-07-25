//
//  SRSItemFactory.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum SRSItemFactory {
    
    static func parseItem(_ json: Any?) -> SRSItem? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        let typeString = json.string(for: "type")
        guard let type = SRSItemType.parse(typeString) else {
            DebugLog.d(caller: self, "Unknown type: \(typeString ?? "nil")")
            return nil
        }
        
        switch type {
        case .button: return SRSButton(json: json)
        case .filler: return SRSFiller(json: json)
        case .icon: return SRSIcon(json: json)
        case .info: return SRSInfo(json: json)
        case .itemList: return SRSItemList(json: json)
        case .label: return SRSLabel(json: json)
        case .separator: return SRSSeparator(json: json)
        }
    }
}
