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
            let metadata = EventMetadata(
                isReply: true,
                isAutomatedMessage: true,
                eventId: 0,
                eventType: .srsResponse,
                issueId: 1,
                sendTime: Date())
            
            describe(".init(text:attachment:quickReplies:metadata:)") {
                let attachment = ChatMessageAttachment(content: "")
                
                context("without text, an attachment, and quickReplies") {
                    it("is nil") {
                        let msg = ChatMessage(text: nil, attachment: nil, buttons: nil, quickReplies: nil, metadata: metadata)
                        expect(msg).to(beNil())
                    }
                }
                
                context("without text") {
                    it("is not nil") {
                        let msg = ChatMessage(text: nil, attachment: attachment, buttons: nil, quickReplies: [], metadata: metadata)
                        expect(msg).toNot(beNil())
                    }
                }
                
                context("without an attachment") {
                    it("is not nil") {
                        let msg = ChatMessage(text: "foo", attachment: nil, buttons: nil, quickReplies: [], metadata: metadata)
                        expect(msg).toNot(beNil())
                    }
                }
                
                context("without quickReplies") {
                    it("is not nil") {
                        let msg = ChatMessage(text: "foo", attachment: attachment, buttons: nil, quickReplies: nil, metadata: metadata)
                        expect(msg).toNot(beNil())
                    }
                }
                
                context("with an empty quickReplies array") {
                    it("has a nil quickReplies property") {
                        let msg = ChatMessage(text: "", attachment: attachment, buttons: nil, quickReplies: [], metadata: metadata)
                        expect(msg).toNot(beNil())
                        expect(msg!.quickReplies).to(beNil())
                    }
                }
                
                context("with an attachment quick reply") {
                    it("has the attachment quick reply") {
                        let attachment = ChatMessageAttachment(content: Component(id: "a", name: "a", value: "foo", isChecked: nil, style: ComponentStyle(), styles: nil, content: nil) as Any)
                        let quickReply = QuickReply(title: "bar", action: Action(content: "baz")!, icon: nil, isTransient: false)
                        let msg = ChatMessage(text: "", attachment: attachment, buttons: nil, quickReplies: [quickReply], metadata: metadata)
                        expect(msg).toNot(beNil())
                        expect(msg!.quickReplies).toNot(beNil())
                        expect(msg!.quickReplies).to(equal([quickReply]))
                    }
                }
                
                context("with duplicate quick replies") {
                    it("has the correct number of buttons and quick replies") {
                        let msg = ChatMessage(text: "", attachment: nil, buttons: [
                            QuickReply(title: "First", action: Action(content: "1")!, icon: nil, isTransient: false),
                            QuickReply(title: "Second", action: Action(content: "2")!, icon: nil, isTransient: false)
                        ], quickReplies: [
                            QuickReply(title: "First", action: WebPageAction(content: ["url": "http://asapp.com"])!, icon: nil, isTransient: true),
                            QuickReply(title: "First", action: Action(content: "1")!, icon: nil, isTransient: false),
                            QuickReply(title: "Second", action: Action(content: "2")!, icon: nil, isTransient: false),
                            QuickReply(title: "Third", action: Action(content: "3")!, icon: nil, isTransient: false)
                        ], metadata: metadata)
                        expect(msg).toNot(beNil())
                        expect(msg!.buttons!.count).to(equal(2))
                        expect(msg!.quickReplies!.count).to(equal(3))
                    }
                }
            }
            
            describe(".fromJson(_:with:)") {
                context("without json") {
                    it("returns nil") {
                        let msg = ChatMessage.fromJSON(nil, with: metadata)
                        expect(msg).to(beNil())
                    }
                }
                
                context("with a json argument that isn't a dictionary") {
                    it("returns nil") {
                        let msg = ChatMessage.fromJSON("just a string", with: metadata)
                        expect(msg).to(beNil())
                    }
                }
                
                context("with JSON containing a quick reply with a component view action") {
                    it("returns a ChatMessage with a quick reply that is a message action") {
                        let dict = TestUtil.dictForFile(named: "security-pin")
                        let msg = ChatMessage.fromJSON(dict, with: metadata)
                        expect(msg).toNot(beNil())
                        expect(msg!.text).to(contain("security PIN"))
                        
                        expect(msg!.hasQuickReplies).to(equal(true))
                        let action = msg!.buttons?.first?.action as? ComponentViewAction
                        expect(action).toNot(beNil())
                        expect(action?.name).to(contain("new_pin"))
                    }
                }
            }
        }
    }
}
