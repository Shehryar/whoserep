//
//  QuickReplyCellSpec.swift
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

class QuickReplyCellSpec: QuickSpec {
    override func spec() {
        describe("QuickReplyCell") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
            }
            
            context("on its own") {
                beforeEach {
                    ASAPP.styles = ASAPPStyles()
                }
                
                context("with default styles") {
                    it("has a valid snapshot") {
                        let cell = QuickReplyCell(style: .default, reuseIdentifier: "quickReplyCell")
                        cell.frame = CGRect(x: 0, y: 0, width: 320, height: 40)
                        let colors = ASAPPButtonColors(
                            backgroundColor: UIColor(red: 0.972, green: 0.969, blue: 0.968, alpha: 1),
                            textColor: UIColor(red: 91.0 / 255.0, green: 101.0 / 255.0, blue: 126.0 / 255.0, alpha: 1))
                        let textStyle = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: colors.textNormal)
                        ASAPP.styles.textStyles.body = textStyle
                        cell.label.font = textStyle.font
                        cell.label.setAttributedText(
                            "Schedule an appointment to return equipment",
                            textType: .body,
                            color: colors.textNormal)
                        cell.label.textAlignment = .center
                        cell.separatorBottomColor = UIColor(red: 0.816, green: 0.824, blue: 0.847, alpha: 0.5)
                        cell.imageTintColor = colors.textNormal
                        expect(cell).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
