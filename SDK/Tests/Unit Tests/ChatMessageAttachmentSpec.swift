//
//  ChatMessageAttachmentSpec.swift
//  Unit Tests
//
//  Created by Hans Hyttinen on 10/20/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import Quick
import Nimble
@testable import ASAPP

class ChatMessageAttachmentSpec: QuickSpec {
    override func spec() {
        describe("ChatMessageAttachment") {
            describe(".init(content:requiresNoContainer:") {
                context("with unidentifiable content") {
                    it("creates an instance with no attachment type, image, or template") {
                        let attachment = ChatMessageAttachment(content: [])
                        expect(attachment.type).to(equal(ChatMessageAttachment.AttachmentType.none))
                        expect(attachment.image).to(beNil())
                        expect(attachment.template).to(beNil())
                        expect(attachment.requiresNoContainer).to(equal(false))
                    }
                }
                
                context("with an image and requires no container") {
                    it("creates an instance with an image that requires no container") {
                        let image = ChatMessageImage(url: URL(string: "test")!, width: 0, height: 0)
                        let attachment = ChatMessageAttachment(content: image, requiresNoContainer: true)
                        expect(attachment.type).to(equal(ChatMessageAttachment.AttachmentType.image))
                        expect(attachment.image).to(equal(image))
                        expect(attachment.template).to(beNil())
                        expect(attachment.requiresNoContainer).to(equal(true))
                    }
                }
                
                context("with a component template") {
                    it("creates an instance with a template") {
                        let value = "foo"
                        let component = Component(id: "a", name: "a", value: value, isChecked: nil, style: ComponentStyle(), styles: nil, content: nil)
                        let attachment = ChatMessageAttachment(content: component as Any)
                        expect(attachment.type).to(equal(ChatMessageAttachment.AttachmentType.template))
                        expect(attachment.image).to(beNil())
                        expect(attachment.template).to(equal(component))
                        expect(attachment.requiresNoContainer).to(equal(false))
                        expect(attachment.currentValue as? String).to(equal(value))
                    }
                }
            }
            
            describe(".fromJSON(_:)") {
                context("with invalid JSON") {
                    it("returns nil") {
                        let attachment = ChatMessageAttachment.fromJSON([])
                        expect(attachment).to(beNil())
                    }
                }
                
                context("without the type property") {
                    it("returns nil") {
                        let attachment = ChatMessageAttachment.fromJSON(["foo": true])
                        expect(attachment).to(beNil())
                    }
                }
                
                context("with an unknown type property value") {
                    it("returns nil") {
                        let attachment = ChatMessageAttachment.fromJSON(["type": "foo"])
                        expect(attachment).to(beNil())
                    }
                }
                
                context("with a type property value of none") {
                    it("returns nil") {
                        let attachment = ChatMessageAttachment.fromJSON(["type": "AttachmentTypeNone", "content": [:]])
                        expect(attachment).to(beNil())
                    }
                }
                
                context("without a content payload") {
                    it("returns nil") {
                        let attachment = ChatMessageAttachment.fromJSON(["type": "image"])
                        expect(attachment).to(beNil())
                    }
                }
                
                context("describing an image") {
                    it("returns an image attachment") {
                        let url = "test"
                        let size: CGFloat = 100
                        let attachment = ChatMessageAttachment.fromJSON([
                            "type": "image",
                            "content": [
                                "url": url,
                                "width": size,
                                "height": size
                            ]
                        ])
                        let image = ChatMessageImage(url: URL(string: url)!, width: size, height: size)
                        expect(attachment?.type).to(equal(ChatMessageAttachment.AttachmentType.image))
                        expect(attachment?.image?.url).to(equal(image.url))
                        expect(attachment?.image?.width).to(equal(image.width))
                        expect(attachment?.image?.height).to(equal(image.height))
                        expect(attachment?.template).to(beNil())
                        expect(attachment?.requiresNoContainer).to(equal(false))
                    }
                }
                
                context("describing a component view") {
                    it("returns a template attachment") {
                        let text = "Test Label"
                        let attachment = ChatMessageAttachment.fromJSON([
                            "type": "componentView",
                            "content": [
                                "formatVersion": 1,
                                "root": [
                                    "type": "label",
                                    "content": [
                                        "text": text
                                    ]
                                ]
                            ],
                            "requiresNoContainer": true
                        ])
                        expect(attachment?.type).to(equal(ChatMessageAttachment.AttachmentType.template))
                        expect(attachment?.image).to(beNil())
                        expect(attachment?.template).to(beAKindOf(LabelItem.self))
                        expect((attachment?.template as? LabelItem)?.text).to(equal(text))
                        expect(attachment?.requiresNoContainer).to(equal(true))
                    }
                }
            }
        }
    }
}
