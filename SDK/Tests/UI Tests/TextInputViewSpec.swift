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
                
                TestUtil.setUpASAPP()
            }
            
            context("on its own") {
                var style: ComponentStyle!
                
                beforeEach {
                    ASAPP.styles = ASAPPStyles()
                    ASAPP.styles.textStyles.body = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: .blue)
                    ASAPP.styles.colors.controlSecondary = .blue
                    ASAPP.styles.colors.controlTint = .brown
                    
                    style = TestUtil.createStyle()
                }
                
                context("with a placeholder") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "Type your message..."
                        ]
                        let textInputItem = TextInputItem(style: style, content: content)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        textInputView.component = textInputItem
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
                
                context("without a placeholder") {
                    it("has a valid snapshot") {
                        let textInputItem = TextInputItem(style: style)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
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
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        textInputView.component = textInputItem
                        textInputView.textInputView.text = "hunter2"
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
                
                context("without password mode on") {
                    it("has a valid snapshot") {
                        let textInputItem = TextInputItem(style: style)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        textInputView.component = textInputItem
                        textInputView.textInputView.text = "the quick brown fox jumps over the lazy dog"
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
                
                context("with the required flag set") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "NAME"
                        ]
                        let textInputItem = TextInputItem(isRequired: true, style: style, content: content)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        textInputView.component = textInputItem
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
                
                context("marked invalid with a long error message") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "NAME"
                        ]
                        let textInputItem = TextInputItem(isRequired: true, style: style, content: content)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        textInputView.component = textInputItem
                        textInputView.updateError(for: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas elementum magna sed arcu sagittis")
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
                
                context("marked invalid with the required flag set") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "NAME"
                        ]
                        let textInputItem = TextInputItem(isRequired: true, style: style, content: content)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        textInputView.component = textInputItem
                        textInputView.textInputView.invalid = true
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
                
                context("marked invalid with an error message with the required flag set") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "NAME"
                        ]
                        let textInputItem = TextInputItem(isRequired: true, style: style, content: content)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        textInputView.component = textInputItem
                        textInputView.updateError(for: "CANNOT BE EMPTY")
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
                
                context("after typing after being marked invalid with the required flag set") {
                    it("has a valid snapshot") {
                        let content = [
                            "placeholder": "NAME"
                        ]
                        let textInputItem = TextInputItem(isRequired: true, style: style, content: content)
                        let textInputView = TextInputView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        textInputView.component = textInputItem
                        textInputView.isInvalid = true
                        textInputView.updateError(for: "CANNOT BE EMPTY")
                        textInputView.becomeFirstResponder()
                        textInputView.textInputView.text = "foo"
                        textInputView.textInputView.textFieldTextDidChange()
                        expect(textInputView.isInvalid).to(equal(false))
                        expect(textInputView).to(haveValidSnapshot())
                    }
                }
                
                context("in a stack view") {
                    var style: ComponentStyle!
                    var itemStyle: ComponentStyle!
                    var stackView: StackView!
                    
                    beforeEach {
                        style = TestUtil.createStyle()
                        style.backgroundColor = .white
                        style.borderColor = nil
                        style.borderWidth = 0
                        style.cornerRadius = 0
                        style.margin = .zero
                        style.padding = UIEdgeInsets(top: 40, left: 20, bottom: 40, right: 20)
                        
                        itemStyle = style
                        itemStyle.margin = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                        itemStyle.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                        itemStyle.alignment = .fill
                        
                        stackView = StackView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
                    }
                    
                    context("with text") {
                        it("has a valid snapshot") {
                            let content: [String: Any] = [
                                "placeholder": "Type your message"
                            ]
                            let textInputItem = TextInputItem(isRequired: true, style: itemStyle, content: content)!
                            stackView.component = StackViewItem(orientation: .vertical, items: [textInputItem], style: style)
                            let textInputView = stackView.nestedComponentViews!.first as! TextInputView
                            textInputView.becomeFirstResponder()
                            textInputView.textInputView.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas elementum magna sed arcu sagittis"
                            textInputView.textInputView.textFieldTextDidChange()
                            textInputView.resignFirstResponder()
                            expect(stackView).to(haveValidSnapshot())
                        }
                    }
                    
                    context("marked invalid with a long error message") {
                        it("has a valid snapshot") {
                            let content: [String: Any] = [
                                "placeholder": "Type your message"
                            ]
                            let textInputItem = TextInputItem(isRequired: true, style: itemStyle, content: content)!
                            stackView.component = StackViewItem(orientation: .vertical, items: [textInputItem], style: style)
                            let textInputView = stackView.nestedComponentViews!.first as! TextInputView
                            textInputView.becomeFirstResponder()
                            textInputView.textInputView.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas elementum magna sed arcu sagittis"
                            textInputView.textInputView.textFieldTextDidChange()
                            textInputView.resignFirstResponder()
                            textInputView.updateError(for: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas elementum magna sed arcu sagittis")
                            expect(stackView).to(haveValidSnapshot())
                        }
                    }
                }
            }
        }
    }
}
