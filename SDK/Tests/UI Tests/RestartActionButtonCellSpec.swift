//
//  RestartActionButtonCellSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 1/30/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class RestartActionButtonCellSpec: QuickSpec {
    override func spec() {
        describe("RestartActionButtonCell") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("on its own") {
                beforeEach {
                    ASAPP.styles = ASAPPStyles()
                }
                
                context("with default styles") {
                    it("has a valid snapshot") {
                        let cell = RestartActionButtonCell(style: .default, reuseIdentifier: "restartActionButtonCell")
                        cell.frame = CGRect(x: 0, y: 0, width: 320, height: 80)
                        let string = "Ask a new question"
                        let style = ASAPPTextStyle(font: Fonts.default.bold, size: 11, letterSpacing: 0.5, color: .white, uppercase: true)
                        let colors = ASAPPButtonColors(
                            backgroundColor: UIColor.ASAPP.eggplant,
                            textColor: .white,
                            border: UIColor.ASAPP.eggplant)
                        cell.button.setBackgroundColor(colors.backgroundNormal, forState: .normal)
                        cell.button.setBackgroundColor(colors.backgroundNormal, forState: .highlighted)
                        cell.button.foregroundColor = colors.textNormal
                        cell.button.label.setAttributedText(string, textStyle: style)
                        expect(cell).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
