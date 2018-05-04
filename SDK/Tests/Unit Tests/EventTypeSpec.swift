//
//  EventTypeSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/23/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class EventTypeSpec: QuickSpec {
    override func spec() {
        describe("EventType") {
            describe(".getLiveChatStatus(for:)") {
                context("with switchSRSToChat") {
                    it("returns true") {
                        expect(EventType.getLiveChatStatus(for: .switchSRSToChat)).to(equal(true))
                    }
                }
                
                context("with newRep") {
                    it("returns true") {
                        expect(EventType.getLiveChatStatus(for: .newRep)).to(equal(true))
                    }
                }
                
                context("with switchSRSToChat") {
                    it("returns false") {
                        expect(EventType.getLiveChatStatus(for: .conversationEnd)).to(equal(false))
                    }
                }
                
                context("with switchSRSToChat") {
                    it("returns false") {
                        expect(EventType.getLiveChatStatus(for: .switchChatToSRS)).to(equal(false))
                    }
                }
            }
        }
    }
}
