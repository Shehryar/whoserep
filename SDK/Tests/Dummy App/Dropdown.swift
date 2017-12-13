//
//  Dropdown.swift
//  Tests
//
//  Created by Hans Hyttinen on 12/13/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP

class Dropdown: SingleComponentViewController {
    override var component: Component {
        return DropdownItem(style: itemStyle, content: [
            "placeholder": "CHOOSE AN OPTION",
            "options": [
                ["text": "A", "value": 0],
                ["text": "B", "value": 2],
                ["text": "C", "value": 4],
                ["text": "D", "value": 8]
            ]
        ])!
    }
}

extension Dropdown: IdentifiableTestCase {
    static var testCaseIdentifier = "dropdown"
}
