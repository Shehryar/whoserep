//
//  TitleButtonContainer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TitleButtonContainer: NSObject {

    let title: String
    let button: SRSButtonItem?
    let content: Component
    
    init(title: String, button: SRSButtonItem?, content: Component) {
        self.title = title
        self.button = button
        self.content = content
        super.init()
    }
}
