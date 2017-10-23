//
//  ButtonSpec.swift
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

class ButtonSpec: QuickSpec {
    override func spec() {
        describe("Button") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test")
                ASAPP.initialize(with: config)
                ASAPP.user = ASAPPUser(userIdentifier: "test", requestContextProvider: {
                    return [:]
                }, userLoginHandler: { _ in })
            }
            
            context("on its own") {
                beforeEach {
                    ASAPP.styles = ASAPPStyles()
                }
                
                context("with default styles") {
                    it("has a valid snapshot") {
                        let button = Button(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
                        button.setBackgroundColor(.white, forState: .normal)
                        button.title = "Testing"
                        expect(button).to(haveValidSnapshot())
                    }
                }
                
                context("with custom styles") {
                    it("has a valid snapshot") {
                        let button = Button(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
                        button.font = ASAPP.styles.textStyles.body.font
                        button.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
                        let buttonColors = ASAPPButtonColors(backgroundColor: UIColor(red: 0.475, green: 0.486, blue: 0.549, alpha: 1))
                        button.setForegroundColor(buttonColors.textNormal, forState: .normal)
                        button.setBackgroundColor(buttonColors.backgroundNormal, forState: .normal)
                        button.layer.cornerRadius = 20.0
                        button.clipsToBounds = true
                        button.title = "Testing"
                        expect(button).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
