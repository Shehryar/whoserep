//
//  ChatMessageSpec.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class ChatMessageSpec: QuickSpec {
    override func spec() {
        describe("ChatMessage") {
            describe(".fromLegacySRSJSON(_:with:)") {
                let eventMetadata = EventMetadata(
                    isReply: true,
                    isAutomatedMessage: true,
                    eventId: 0,
                    eventType: .srsResponse,
                    issueId: 1,
                    sendTime: Date())
                
                context("without valid JSON") {
                    it("returns nil") {
                        let msg = ChatMessage.fromLegacySRSJSON(nil, with: eventMetadata)
                        expect(msg).to(beNil())
                    }
                }
                
                context("with contentType of carousel") {
                    it("returns nil") {
                        let json = TestUtil.jsonForFile(named: "phone-plan-upgrade")
                        let msg = ChatMessage.fromLegacySRSJSON(json, with: eventMetadata)
                        expect(msg).to(beNil())
                    }
                }
                
                context("without a message component") {
                    it("returns nil") {
                        let json = TestUtil.jsonForFile(named: "transaction-history")
                        let msg = ChatMessage.fromLegacySRSJSON(json, with: eventMetadata)
                        expect(msg).to(beNil())
                    }
                }
                
                context("with a new credit card") {
                    var json: [String: Any]!
                    var msg: ChatMessage!
                    
                    beforeEach {
                        json = TestUtil.jsonForFile(named: "add-credit-card")
                        msg = ChatMessage.fromLegacySRSJSON(json, with: eventMetadata)
                    }
                    
                    it("has Make a Payment as its first quick reply") {
                        expect(msg).toNot(beNil())
                        
                        expect(msg!.text).to(contain("add a credit card"))
                        
                        let firstReply = msg!.quickReplies?.first
                        expect(firstReply).toNot(beNil())
                        expect(firstReply!.title).to(equal("Make a Payment"))
                        expect(firstReply!.action).to(beAKindOf(DeepLinkAction.self))
                        
                        let action = firstReply!.action as! DeepLinkAction
                        expect(action.name).to(equal("payment"))
                    }
                    
                    it("has a StackView as an attachment") {
                        expect(msg).toNot(beNil())
                        expect(msg.attachment?.template).toNot(beNil())
                        expect(msg.attachment!.template!).to(beAKindOf(StackViewItem.self))
                    }
                }
            }
        }
    }
}
