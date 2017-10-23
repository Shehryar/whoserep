//
//  BubbleViewSpec.swift
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

class BubbleViewSpec: QuickSpec {
    override func spec() {
        describe("BubbleView") {
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
                        let bubbleView = BubbleView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
                        expect(bubbleView).to(haveValidSnapshot())
                    }
                }
                
                context("with custom rounded corners") {
                    it("has a valid snapshot") {
                        let bubbleView = BubbleView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
                        bubbleView.roundedCorners = [.bottomLeft]
                        expect(bubbleView).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
