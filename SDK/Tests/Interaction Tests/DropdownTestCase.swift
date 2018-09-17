//
//  DropdownTestCase.swift
//  Tests
//
//  Created by Hans Hyttinen on 12/13/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import XCTest
@testable import ASAPP

class DropdownTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    func testSelection() {
        let app = XCUIApplication()
        app.launchArguments.append(Dropdown.testCaseIdentifier)
        app.launch()
        
        let field = app.textFields.firstMatch
        XCTAssert(field.exists)
        field.forceTap()
        let picker = app.pickerWheels.firstMatch
        XCTAssert(picker.exists)
        picker.adjust(toPickerWheelValue: "C")
        app.toolbars.buttons.firstMatch.forceTap()
        
        XCTAssert(field.value as? String == "C")
        let pickerWheel = app.pickerWheels.firstMatch
        XCTAssert(waitForElementToDisappear(pickerWheel) || !pickerWheel.exists)
        
        field.forceTap()
        picker.adjust(toPickerWheelValue: "A")
        app.toolbars.buttons.firstMatch.forceTap()
        
        XCTAssert(field.value as? String == "A")
        XCTAssert(!app.pickerWheels.firstMatch.exists)
    }
    
    func waitForElementToDisappear(_ element: XCUIElement) -> Bool {
        if !element.exists {
            return true
        }
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: 10) == .completed
    }
}
