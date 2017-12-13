//
//  DropdownViewSpec.swift
//  Tests
//
//  Created by Hans Hyttinen on 12/13/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class DropdownViewSpec: QuickSpec {
    override func spec() {
        describe("DropdownView") {
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
                style.padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
                
                beforeEach {
                    ASAPP.styles = ASAPPStyles()
                    ASAPP.styles.textStyles.body = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: .blue)
                    ASAPP.styles.colors.controlSecondary = .blue
                    ASAPP.styles.colors.controlTint = .brown
                    
                    style = configStyle()
                }
                
                context("with a placeholder") {
                    it("has a valid snapshot") {
                        let content: [String: Any] = [
                            "placeholder": "CHOOSE AN OPTION",
                            "options": [
                                ["text": "A", "value": "A"],
                                ["text": "B", "value": "B"]
                            ]
                        ]
                        let dropdownItem = DropdownItem(style: style, content: content)
                        let dropdownView = DropdownView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        dropdownView.component = dropdownItem
                        expect(dropdownView).to(haveValidSnapshot())
                    }
                }
                
                context("without a placeholder") {
                    it("has a valid snapshot") {
                        let content: [String: Any] = [
                            "options": [
                                ["text": "A", "value": "A"],
                                ["text": "B", "value": "B"]
                            ]
                        ]
                        let dropdownItem = DropdownItem(style: style, content: content)
                        let dropdownView = DropdownView(frame: CGRect(x: 0, y: 0, width: 250, height: 70))
                        dropdownView.component = dropdownItem
                        expect(dropdownView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
