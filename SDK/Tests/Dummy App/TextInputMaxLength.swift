//
//  TextInputMaxLength.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/25/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP

class TextInputMaxLength: SingleComponentViewController {
    override var component: Component {
        return TextInputItem(style: itemStyle, content: [
            "maxLength": 20
        ])!
    }
}

extension TextInputMaxLength: IdentifiableTestCase {
    static var testCaseIdentifier = "textInputMaxLength"
}
