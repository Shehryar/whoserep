//
//  TextInputViewTestCase.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/25/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import XCTest
@testable import ASAPP

class TextInputViewTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    func testMaxLength() {
        let app = XCUIApplication()
        app.launchArguments.append(TextInputMaxLength.testCaseIdentifier)
        app.launch()
        
        let textInput = app.textFields.firstMatch
        textInput.forceTap()
        let text = "the quick brown fox jumps over the lazy dog"
        textInput.typeText(text)
        XCTAssert(text.characters.count > 20)
        XCTAssertNotNil(textInput.value as? String)
        XCTAssert((textInput.value as! String).characters.count == 20)
    }
}
