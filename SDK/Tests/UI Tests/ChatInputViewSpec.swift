//
//  ChatInputViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/19/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ChatInputViewSpec: QuickSpec {
    override func spec() {
        describe("ChatInputView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
            }
            
            context("on its own") {
                beforeEach {
                    ASAPP.strings = ASAPPStrings()
                    ASAPP.styles = ASAPPStyles()
                }
                
                context("with default styles") {
                    it("has a valid snapshot") {
                        let input = ChatInputView()
                        input.frame = CGRect(x: 0, y: 0, width: 320, height: 88)
                        input.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 0)
                        input.bubbleInset = UIEdgeInsets(top: 0, left: 20, bottom: 30, right: 20)
                        input.bubbleView.layer.cornerRadius = 20
                        input.displayBorderTop = false
                        input.updateDisplay()
                        expect(input).to(haveValidSnapshot())
                    }
                }
                
                context("with the media button hidden") {
                    it("has a valid snapshot") {
                        let input = ChatInputView()
                        input.frame = CGRect(x: 0, y: 0, width: 320, height: 88)
                        input.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 0)
                        input.bubbleInset = UIEdgeInsets(top: 0, left: 20, bottom: 30, right: 20)
                        input.bubbleView.layer.cornerRadius = 20
                        input.displayBorderTop = false
                        input.textView.text = "The quick brown fox jumps over the lazy dog."
                        input.displayMediaButton = false
                        input.sendButtonText = "Send"
                        input.updateDisplay()
                        expect(input).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
