//
//  TextAreaViewTestCase.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/24/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import XCTest
@testable import ASAPP

class TextAreaViewTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    func testMaxLength() {
        let app = XCUIApplication()
        app.launchArguments.append(TextAreaMaxLength.testCaseIdentifier)
        app.launch()
        
        let textView = app.textViews.firstMatch
        textView.forceTap()
        let text = "the quick brown fox jumps over the lazy dog"
        textView.typeText(text)
        XCTAssert(text.count > 20)
        XCTAssertNotNil(textView.value as? String)
        XCTAssert((textView.value as! String).count == 20)
    }
}
