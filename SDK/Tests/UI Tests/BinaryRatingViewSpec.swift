//
//  BinaryRatingViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 11/9/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class BinaryRatingViewSpec: QuickSpec {
    override func spec() {
        describe("BinaryRatingView") {
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
                
                beforeEach {
                    style = configStyle()
                }
                
                context("with Yes and No text") {
                    it("has a valid snapshot") {
                        let content = [
                            "positiveValue": "1",
                            "negativeValue": "0",
                            "positiveText": "YES",
                            "negativeText": "NO"
                        ]
                        let binaryRatingItem = BinaryRatingItem(style: style, content: content)
                        let binaryRatingView = BinaryRatingView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        binaryRatingView.component = binaryRatingItem
                        expect(binaryRatingView).to(haveValidSnapshot())
                    }
                }
                
                context("with long Yes and No text") {
                    it("has a valid snapshot") {
                        let content = [
                            "positiveValue": "1",
                            "negativeValue": "0",
                            "positiveText": "WEEWAWO",
                            "negativeText": "NEDDA"
                        ]
                        let binaryRatingItem = BinaryRatingItem(style: style, content: content)
                        let binaryRatingView = BinaryRatingView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        binaryRatingView.component = binaryRatingItem
                        expect(binaryRatingView).to(haveValidSnapshot())
                    }
                }
                
                context("with textAlign: right") {
                    it("has a valid snapshot") {
                        style.textAlign = .right
                        
                        let content = [
                            "positiveValue": "1",
                            "negativeValue": "0"
                        ]
                        let binaryRatingItem = BinaryRatingItem(style: style, content: content)
                        let binaryRatingView = BinaryRatingView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        binaryRatingView.component = binaryRatingItem
                        expect(binaryRatingView).to(haveValidSnapshot())
                    }
                }
                
                context("with textAlign: center") {
                    it("has a valid snapshot") {
                        style.textAlign = .center
                        
                        let content = [
                            "positiveValue": "1",
                            "negativeValue": "0"
                        ]
                        let binaryRatingItem = BinaryRatingItem(style: style, content: content)
                        let binaryRatingView = BinaryRatingView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        binaryRatingView.component = binaryRatingItem
                        expect(binaryRatingView).to(haveValidSnapshot())
                    }
                }
                
                context("with textAlign: left") {
                    it("has a valid snapshot") {
                        style.textAlign = .left
                        
                        let content = [
                            "positiveValue": "1",
                            "negativeValue": "0"
                        ]
                        let binaryRatingItem = BinaryRatingItem(style: style, content: content)
                        let binaryRatingView = BinaryRatingView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        binaryRatingView.component = binaryRatingItem
                        expect(binaryRatingView).to(haveValidSnapshot())
                    }
                }
                
                context("with positive on the right") {
                    it("has a valid snapshot") {
                        let content = [
                            "positiveValue": "1",
                            "negativeValue": "0",
                            "positiveOnRight": true
                        ] as [String : Any]
                        let binaryRatingItem = BinaryRatingItem(style: style, content: content)
                        let binaryRatingView = BinaryRatingView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        binaryRatingView.component = binaryRatingItem
                        expect(binaryRatingView).to(haveValidSnapshot())
                    }
                }
                
                context("with custom spacing and size") {
                    it("has a valid snapshot") {
                        let content = [
                            "positiveValue": "1",
                            "negativeValue": "0",
                            "circleSpacing": 10,
                            "circleSize": 70
                        ] as [String : Any]
                        let binaryRatingItem = BinaryRatingItem(style: style, content: content)
                        let binaryRatingView = BinaryRatingView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        binaryRatingView.component = binaryRatingItem
                        expect(binaryRatingView).to(haveValidSnapshot())
                    }
                }
                
                context("with custom colors") {
                    it("has a valid snapshot") {
                        let content = [
                            "positiveValue": "1",
                            "negativeValue": "0",
                            "positiveSelectedColor": "#0000ff",
                            "negativeSelectedColor": "#ffff00"
                        ]
                        let binaryRatingItem = BinaryRatingItem(style: style, content: content)
                        let binaryRatingView = BinaryRatingView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        binaryRatingView.component = binaryRatingItem
                        expect(binaryRatingView).to(haveValidSnapshot())
                    }
                }
                
                context("with a positive and negative value") {
                    it("changes its selected value based on the chosen button") {
                        let thumbsUp = "thumbsUp"
                        let thumbsDown = "thumbsDown"
                        let content = [
                            "positiveValue": thumbsUp,
                            "negativeValue": thumbsDown
                        ]
                        let binaryRatingItem = BinaryRatingItem(style: style, content: content)
                        let binaryRatingView = BinaryRatingView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
                        binaryRatingView.component = binaryRatingItem
                        
                        binaryRatingView.setChoice(true, animated: false)
                        expect(binaryRatingItem?.value as? String).to(equal(thumbsUp))
                        
                        binaryRatingView.setChoice(false, animated: false)
                        expect(binaryRatingItem?.value as? String).to(equal(thumbsDown))
                    }
                }
            }
        }
    }
}
