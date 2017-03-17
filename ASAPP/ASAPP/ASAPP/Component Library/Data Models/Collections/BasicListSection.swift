//
//  BasicListSection.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BasicListSection: NSObject {

    let title: String?
    let items: [BasicListItem]
    
    // TODO: item style...
    
    init(title: String?, items: [BasicListItem]) {
        self.title = title
        self.items = items
        super.init()
    }
}
