//
//  FormValidationTestCase.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/25/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import XCTest
@testable import ASAPP

class FormValidationTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    func testEmptyRequiredFieldsMarkedInvalid() {
        let app = XCUIApplication()
        app.launchArguments.append(FormValidation.testCaseIdentifier)
        app.launch()
        
        XCTAssertFalse(app.staticTexts["Required field"].exists)
        
        let button = app.buttons["OK"]
        button.forceTap()
        
        XCTAssert(app.staticTexts["Required field"].exists)
    }
}
