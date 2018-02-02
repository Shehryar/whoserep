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
                        let string = "I want to ask another question."
                        let style = ASAPPTextStyle(font: Fonts.default.bold, size: 12, letterSpacing: 1, color: UIColor.ASAPP.cometBlue, uppercase: true)
                        let colors = ASAPPButtonColors(
                            backgroundColor: .white,
                            textColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1),
                            border: UIColor(red: 0, green: 0.45, blue: 0.73, alpha: 1))
                        cell.button.updateText(string, textStyle: style, colors: colors)
                        expect(cell).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
