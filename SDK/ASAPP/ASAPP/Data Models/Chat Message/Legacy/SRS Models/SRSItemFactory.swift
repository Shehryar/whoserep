//
//  SRSItemFactory.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum SRSItemFactory {
    
    static func parseItem(_ json: Any?, metadata: EventMetadata) -> SRSItem? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        let typeString = json.string(for: "type")
        guard let type = SRSItemType.parse(typeString) else {
            DebugLog.d(caller: self, "Unknown type: \(typeString ?? "nil")")
            return nil
        }
        
        switch type {
        case .button: return SRSButton(json: json, metadata: metadata)
        case .filler: return SRSFiller(json: json, metadata: metadata)
        case .icon: return SRSIcon(json: json, metadata: metadata)
        case .info: return SRSInfo(json: json, metadata: metadata)
        case .itemList: return SRSItemList(json: json, metadata: metadata)
        case .label: return SRSLabel(json: json, metadata: metadata)
        case .separator: return SRSSeparator(json: json, metadata: metadata)
        }
    }
}
