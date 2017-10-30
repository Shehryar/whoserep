//
//  TextAreaViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/24/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class TextAreaViewSpec: QuickSpec {
    override func spec() {
        describe("TextAreaView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
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
                    style.padding = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
                    style.textType = .body
                }
                
                context("with a placeholder") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "Type your message..."
                        ]
                        let textAreaItem = TextAreaItem(style: style, content: content)
                        let textAreaView = TextAreaView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        textAreaView.component = textAreaItem
                        expect(textAreaView).to(haveValidSnapshot())
                    }
                }
                
                context("without a placeholder") {
                    it("has a valid snapshot") {
                        let textAreaItem = TextAreaItem(style: style)
                        let textAreaView = TextAreaView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        textAreaView.component = textAreaItem
                        expect(textAreaView).to(haveValidSnapshot())
                    }
                }
                
                context("with some text that fits") {
                    it("has a valid snapshot") {
                        let textAreaItem = TextAreaItem(style: style)
                        let textAreaView = TextAreaView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        textAreaView.component = textAreaItem
                        textAreaView.textView.text = "the quick brown fox jumps over the lazy dog"
                        expect(textAreaView).to(haveValidSnapshot())
                    }
                }
                
                context("with a lot of text that does not fit") {
                    it("has a valid snapshot") {
                        let textAreaItem = TextAreaItem(style: style)
                        let textAreaView = TextAreaView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        textAreaView.component = textAreaItem
                        textAreaView.textView.text = """
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus sed vulputate mauris. Morbi sit amet risus ornare, lacinia lorem ut, interdum augue. Suspendisse ornare sit amet lorem sit amet semper.
                        """
                        expect(textAreaView).to(haveValidSnapshot())
                    }
                }
                
                context("with the required flag set") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "NAME"
                        ]
                        let textAreaItem = TextAreaItem(isRequired: true, style: style, content: content)
                        let textAreaView = TextAreaView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        textAreaView.component = textAreaItem
                        expect(textAreaView).to(haveValidSnapshot())
                    }
                }
                
                context("marked invalid with the required flag set") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "NAME"
                        ]
                        let textAreaItem = TextAreaItem(isRequired: true, style: style, content: content)
                        let textAreaView = TextAreaView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        textAreaView.component = textAreaItem
                        textAreaView.isInvalid = true
                        expect(textAreaView).to(haveValidSnapshot())
                    }
                }
                
                context("marked invalid with an error message with the required flag set") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "NAME"
                        ]
                        let textAreaItem = TextAreaItem(isRequired: true, style: style, content: content)
                        let textAreaView = TextAreaView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        textAreaView.component = textAreaItem
                        textAreaView.isInvalid = true
                        textAreaView.updateError(for: "CANNOT BE EMPTY")
                        expect(textAreaView).to(haveValidSnapshot())
                    }
                }
                
                context("after typing after being marked invalid with the required flag set") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "NAME"
                        ]
                        let textAreaItem = TextAreaItem(isRequired: true, style: style, content: content)
                        let textAreaView = TextAreaView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        textAreaView.component = textAreaItem
                        textAreaView.isInvalid = true
                        textAreaView.updateError(for: "CANNOT BE EMPTY")
                        textAreaView.becomeFirstResponder()
                        textAreaView.textView.text = "foo"
                        textAreaView.textViewDidChange(textAreaView.textView)
                        expect(textAreaView.isInvalid).to(equal(false))
                        expect(textAreaView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
