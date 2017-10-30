//
//  TextAreaMaxLength.swift
//  Tests
//
//  Created by Hans Hyttinen on 10/24/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP

class TextAreaMaxLength: SingleComponentViewController {
    override var component: Component {
        return TextAreaItem(style: itemStyle, content: [
            "maxLength": 20
        ])!
    }
}

extension TextAreaMaxLength: IdentifiableTestCase {
    static var testCaseIdentifier = "textAreaMaxLength"
}
