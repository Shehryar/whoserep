//
//  BasicListItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BasicListItem: NSObject {

    let title: String?
    let detail: String?
    let value: String?
    let icon: String?
    
    init(title: String?, detail: String?, value: String?, icon: String?) {
        self.title = title
        self.detail = detail
        self.value = value
        self.icon = icon
        super.init()
    }
}
