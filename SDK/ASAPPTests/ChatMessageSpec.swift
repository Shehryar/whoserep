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
            
            describe(".init(text:attachment:quickReplies:metadata") {
                let attachment = ChatMessageAttachment(content: "")
                
                context("without text, an attachment, and quickReplies") {
                    it("is nil") {
                        let msg = ChatMessage(text: nil, attachment: nil, quickReplies: nil, metadata: metadata)
                        expect(msg).to(beNil())
                    }
                }
                
                context("without text") {
                    it("is not nil") {
                        let msg = ChatMessage(text: nil, attachment: attachment, quickReplies: [:], metadata: metadata)
                        expect(msg).toNot(beNil())
                    }
                }
                
                context("without an attachment") {
                    it("is not nil") {
                        let msg = ChatMessage(text: "foo", attachment: nil, quickReplies: [:], metadata: metadata)
                        expect(msg).toNot(beNil())
                    }
                }
                
                context("without quickReplies") {
                    it("is not nil") {
                        let msg = ChatMessage(text: "foo", attachment: attachment, quickReplies: nil, metadata: metadata)
                        expect(msg).toNot(beNil())
                    }
                }
                
                context("with an empty quickReplies array") {
                    it("has a nil quickReplies property") {
                        let msg = ChatMessage(text: "", attachment: attachment, quickReplies: [:], metadata: metadata)
                        expect(msg).toNot(beNil())
                        expect(msg!.quickReplies).to(beNil())
                    }
                }
                
                context("with an attachment quick reply") {
                    it("has the attachment quick reply") {
                        let attachment = ChatMessageAttachment(content: Component(id: "a", name: "a", value: "foo", isChecked: nil, style: ComponentStyle(), styles: nil, content: nil) as Any)
                        let quickReply = QuickReply(title: "bar", action: Action(content: "baz")!)
                        let otherQuickReply = QuickReply(title: "alpha", action: Action(content: "beta")!)
                        let msg = ChatMessage(text: "", attachment: attachment, quickReplies: [
                            "foo": [quickReply],
                            "other": [otherQuickReply]
                        ], metadata: metadata)
                        expect(msg).toNot(beNil())
                        expect(msg!.quickReplies).toNot(beNil())
                        expect(msg!.quickReplies).to(equal([quickReply]))
                    }
                }
            }
            
            describe(".getAutoSelectQuickReply()") {
                context("without quickReplies") {
                    it("returns nil") {
                        let msg = ChatMessage(text: nil, attachment: nil, quickReplies: [:], metadata: metadata)
                        expect(msg!.getAutoSelectQuickReply()).to(beNil())
                    }
                }
                
                context("without any auto-select quick replies") {
                    it("returns nil") {
                        let msg = ChatMessage(text: nil, attachment: nil, quickReplies: [
                            "foo": [QuickReply(title: "bar", action: Action(content: "")!)]
                        ], metadata: metadata)
                        expect(msg!.getAutoSelectQuickReply()).to(beNil())
                    }
                }
                
                context("with two auto-select quick replies") {
                    it("returns the first one") {
                        let alpha = QuickReply(title: "beta", action: Action(content: "")!, isAutoSelect: true)
                        let gamma = QuickReply(title: "delta", action: Action(content: "")!, isAutoSelect: true)
                        let msg = ChatMessage(text: nil, attachment: nil, quickReplies: [
                            "alpha": [alpha],
                            "gamma": [gamma]
                        ], metadata: metadata)
                        let result = msg!.getAutoSelectQuickReply()
                        expect(result).toNot(beNil())
                        expect(result).to(equal(alpha))
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
                
                context("with legacy JSON") {
                    it("returns a proper ChatMessage") {
                        let json = TestUtil.jsonForFile(named: "add-credit-card")
                        let msg = ChatMessage.fromJSON(json, with: metadata)
                        expect(msg).toNot(beNil())
                        expect(msg!.text).to(contain("add a credit card"))
                        
                        let action = msg!.quickReplies?.first?.action as? DeepLinkAction
                        expect(action).toNot(beNil())
                        expect(action!.name).to(equal("payment"))
                    }
                }
                
                context("with JSON containing a quick reply") {
                    it("returns a ChatMessage with a quick reply") {
                        let json = TestUtil.jsonForFile(named: "security-pin")
                        let msg = ChatMessage.fromJSON(json, with: metadata)
                        expect(msg).toNot(beNil())
                        expect(msg!.text).to(contain("security PIN"))
                        
                        let action = msg!.quickReplies?.first?.action as? ComponentViewAction
                        expect(action).toNot(beNil())
                        expect(action!.name).to(contain("new_pin"))
                    }
                }
            }
            
            describe(".fromLegacySRSJSON(_:with:)") {
                context("without valid JSON") {
                    it("returns nil") {
                        let msg = ChatMessage.fromLegacySRSJSON(nil, with: metadata)
                        expect(msg).to(beNil())
                    }
                }
                
                context("with contentType of carousel") {
                    it("returns nil") {
                        let json = TestUtil.jsonForFile(named: "phone-plan-upgrade")
                        let msg = ChatMessage.fromLegacySRSJSON(json, with: metadata)
                        expect(msg).to(beNil())
                    }
                }
                
                context("without a message component") {
                    it("returns nil") {
                        let json = TestUtil.jsonForFile(named: "live-chat-begin")
                        let msg = ChatMessage.fromLegacySRSJSON(json, with: metadata)
                        expect(msg).to(beNil())
                    }
                }
                
                context("with a new credit card") {
                    var json: [String: Any]!
                    var msg: ChatMessage!
                    
                    beforeEach {
                        json = TestUtil.jsonForFile(named: "add-credit-card")
                        msg = ChatMessage.fromLegacySRSJSON(json, with: metadata)
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
