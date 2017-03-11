//
//  SRSLabelValueItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

enum SRSLabelValueItemType {
    case vertical
    case horizontal
}

class SRSLabelValueItem: NSObject {
    
    let type: SRSLabelValueItemType
    let label: SRSLabelItem?
    let value: SRSLabelItem?
    
    // MARK: Init
    
    init(type: SRSLabelValueItemType, label: SRSLabelItem?, value: SRSLabelItem?) {
        self.type = type
        self.label = label
        self.value = value
        super.init()
    }
}
