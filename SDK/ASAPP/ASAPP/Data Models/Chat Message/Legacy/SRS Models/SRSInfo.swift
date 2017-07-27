//
//  SRSLabelValue.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSInfo: SRSItem {
    
    let label: String?
    
    let labelColor: UIColor?
    
    let value: String?
    
    let valueColor: UIColor?
    
    override init?(json: Any?) {
        guard let json = json as? [String : Any] else {
            return nil
        }
        let label = json.string(for: "label")
        let value = json.string(for: "value")
        guard label != nil || value != nil else {
            DebugLog.d(caller: SRSInfo.self, "Missing label and/or value: \(json)")
            return nil
        }
        self.label = label
        self.labelColor = json.hexColor(for: "labelColor")
        self.value = value
        self.valueColor = json.hexColor(for: "valueColor")
        super.init(json: json)
    }
}
