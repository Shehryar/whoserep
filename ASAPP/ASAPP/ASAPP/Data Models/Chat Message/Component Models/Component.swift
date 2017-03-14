//
//  Component.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- Component

protocol Component {
    var type: ComponentType {get}
    
    static func make(_ json: [String : AnyObject]) -> Component?
}

// MARK:- ComponentType

enum ComponentType: String { // Maintain  alphabetical order
    case basicList = "basic_list"
    case basicListItem = "basic_list_item"
    case basicListSection = "basic_list_section"
    case titleButtonContainer = "title_button_container"
}
