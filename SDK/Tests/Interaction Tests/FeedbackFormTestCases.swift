//
//  FeedbackFormTestCases.swift
//  Interaction Tests
//
//  Created by Shehryar Hussain on 11/26/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import XCTest
@testable import ASAPP

class FeedbackFormTestCases: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    func testButtons() {
        let app = XCUIApplication()
        app.launchArguments.append(FeedbackForm.testCaseIdentifier)
        app.launch()
        
        let rating = findElementContaining(type: .button, name: "3")
        rating.forceTap()
        
        let yesRating = findElementContaining(type: .button, name: "Yes")
        yesRating.forceTap()
        
        let increase = findElementContaining(type: .button, name: "Increase")
        increase.scrollToElement()
        increase.forceTap()
        
        let textView = findElementContaining(type: .textView, name: "Leave a comment (optional)")
        textView.scrollToElement()
        textView.forceTap()
        sleep(2)
        XCTAssert(textView.isVisible)
        
        let submitButton = app.buttons.firstMatch
        submitButton.forceTap()
    }
}
