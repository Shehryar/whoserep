//
//  BasicList.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BasicList: NSObject {
    
    enum SeparatorStyle: String {
        case none = "none"
        case insetLine = "inset_line"
        case line = "line"
    }
    
    let sections: [BasicListSection]
    
    let separatorStyle: SeparatorStyle

    init(sections: [BasicListSection], separatorStyle: SeparatorStyle? = nil) {
        self.sections = sections
        self.separatorStyle = separatorStyle ?? .none
        super.init()
    }
}
