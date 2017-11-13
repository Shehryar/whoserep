//
//  ButtonViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 11/13/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ButtonViewSpec: QuickSpec {
    override func spec() {
        describe("ButtonView") {
            func configStyle() -> ComponentStyle {
                ASAPP.styles = ASAPPStyles()
                ASAPP.styles.textStyles.body = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: .blue)
                ASAPP.styles.colors.controlSecondary = .blue
                ASAPP.styles.colors.controlTint = .brown
                
                var style = ComponentStyle()
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
                
                return style
            }
            
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
                var content: [String: Any]!
                
                beforeEach {
                    ASAPP.styles = ASAPPStyles()
                    ASAPP.styles.textStyles.body = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: .blue)
                    ASAPP.styles.colors.controlSecondary = .blue
                    ASAPP.styles.colors.controlTint = .brown
                    
                    style = configStyle()
                    
                    content = [
                        "title": "Button",
                        "action": [
                            "type": "api",
                            "content": [
                                "requestPath": "foo"
                            ]
                        ]
                    ]
                }
                
                context("with primaryButtonsRounded set to false") {
                    it("has a valid snapshot") {
                        ASAPP.styles.shapeStyles.primaryButtonsRounded = false
                        let buttonItem = ButtonItem(style: style, content: content)
                        let buttonView = ButtonView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        buttonView.component = buttonItem
                        expect(buttonView).to(haveValidSnapshot())
                    }
                }
                
                context("with primaryButtonsRounded set to true") {
                    it("has a valid snapshot") {
                        ASAPP.styles.shapeStyles.primaryButtonsRounded = true
                        let buttonItem = ButtonItem(style: style, content: content)
                        let buttonView = ButtonView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        buttonView.component = buttonItem
                        expect(buttonView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
