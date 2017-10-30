//
//  TextInputViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/23/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class TextInputViewSpec: QuickSpec {
    override func spec() {
        describe("TextInputView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
            }
            
            context("on its own") {
                var style: ComponentStyle!
                
                beforeEach {
                    ASAPP.styles = ASAPPStyles()
                    ASAPP.styles.textStyles.body = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: .blue)
                    ASAPP.styles.colors.controlSecondary = .blue
                    ASAPP.styles.colors.controlTint = .brown
                    
                    style = ComponentStyle()
                    style.alignment = .center
                    style.backgroundColor = .white
                    style.borderColor = .red
                    style.borderWidth = 1
                    style.color = .blue
                    style.cornerRadius = 10
                    style.fontSize = 22
                    style.letterSpacing = 0.5
                    style.margin = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                    style.padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                    style.textType = .body
                }
                
                context("with a placeholder") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "Type your message..."
                        ]
                        let textInputItem = TextInputItem(style: style, content: content)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        textInputView.component = textInputItem
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
                
                context("without a placeholder") {
                    it("has a valid snapshot") {
                        let textInputItem = TextInputItem(style: style)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        textInputView.component = textInputItem
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
                
                context("with password mode on") {
                    it("has a valid snapshot") {
                        let content = [
                            "password": true
                        ]
                        let textInputItem = TextInputItem(style: style, content: content)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        textInputView.component = textInputItem
                        textInputView.textInputView.text = "hunter2"
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
                
                context("without password mode on") {
                    it("has a valid snapshot") {
                        let textInputItem = TextInputItem(style: style)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
                        textInputView.component = textInputItem
                        textInputView.textInputView.text = "the quick brown fox jumps over the lazy dog"
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
