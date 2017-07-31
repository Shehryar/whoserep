//
//  SRSTests.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import XCTest
@testable import ASAPP

class SRSTests: XCTestCase {

    let eventMetadata = EventMetadata(isReply: true,
                                      isAutomatedMessage: true,
                                      eventId: 0,
                                      eventType: .srsResponse,
                                      issueId: 1,
                                      sendTime: Date())
    
    func testAddCreditCard() {
        guard let json = TestUtil.jsonForFile(named: "add-credit-card") else {
            XCTAssertTrue(false)
            return
        }
        
        let chatMessage = ChatMessage.fromLegacySRSJSON(json, with: eventMetadata)
        XCTAssertEqual(chatMessage?.text,
                       "Currently, we don't have a credit card saved to your account. Please add a credit card to continue")
        
        XCTAssertEqual(chatMessage?.quickReplies?.first?.title, "Make a Payment")
        if let action = chatMessage?.quickReplies?.first?.action as? DeepLinkAction {
            XCTAssertEqual(action.name, "payment")
        } else {
            XCTFail()
        }
        
        
    }
}
