//
//  ASAPPTests.swift
//  ASAPPTests
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import XCTest
@testable import ASAPP

class ASAPPTests: XCTestCase {
    
    func testCanHandleNotification() {
        XCTAssertTrue(ASAPP.canHandleNotification(
            with: [
                "aps": [
                    "asapp": true
                ]
            ]))
        
        XCTAssertFalse(ASAPP.canHandleNotification(
            with: [
                "aps": [
                    "asapp": false
                ]
            ]))
        
        XCTAssertTrue(ASAPP.canHandleNotification(
            with: [
                "aps": [
                    "asapp": [
                        "data": "someData"
                    ]
                ]
            ]))
        
        XCTAssertFalse(ASAPP.canHandleNotification(
            with: [
                "aps": [
                    
                ]
            ]))
        
        XCTAssertTrue(ASAPP.canHandleNotification(
            with: [
                "asapp": [
                    "data": "someData"
                ]
            ]))
        
        XCTAssertFalse(ASAPP.canHandleNotification(with: nil))
        
        XCTAssertFalse(ASAPP.canHandleNotification(
            with: [
                "data": "someData"
            ]))
    }
}
