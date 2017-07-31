//
//  SRSItemList.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSItemList: SRSItem {
    
    enum Orientation: String {
        case vertical = "vertical"
        case horizontal = "horizontal"
    
        static func parse(_ value: Any?) -> Orientation? {
            guard let value = value as? String else {
                return nil
            }
            return Orientation(rawValue: value)
        }
    }
    
    let orientation: Orientation
    
    let items: [SRSInfo]

    override init?(json: Any?) {
        guard let json = json as? [String : Any] else {
            return nil
        }
        guard let itemsJSON = json["value"] as? [[String : Any]] else {
            DebugLog.d(caller: SRSItemList.self, "Missing value items")
            return nil
        }
        
        var items = [SRSInfo]()
        for itemJSON in itemsJSON {
            if let infoItem = SRSItemFactory.parseItem(itemJSON) as? SRSInfo {
                items.append(infoItem)
            } else {
                DebugLog.d(caller: SRSItemList.self, "Invalid itemJSON in SRSItemList: \(itemJSON)")
            }
        }
        guard !items.isEmpty else {
            DebugLog.d(caller: SRSItemList.self, "Empty items!")
            return nil
        }
        
        self.orientation = Orientation.parse(json["orientation"]) ?? .vertical
        self.items = items
        super.init(json: json)
    }
}
