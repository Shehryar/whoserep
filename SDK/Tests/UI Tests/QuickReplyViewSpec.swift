//
//  QuickReplyViewSpec.swift
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

class QuickReplyViewSpec: QuickSpec {
    override func spec() {
        describe("QuickReplyView") {
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
                    
                    let colors = ASAPPButtonColors(
                        backgroundColor: UIColor(red: 0.972, green: 0.969, blue: 0.968, alpha: 1),
                        textColor: UIColor(red: 91.0 / 255.0, green: 101.0 / 255.0, blue: 126.0 / 255.0, alpha: 1))
                    let textStyle = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: colors.textNormal)
                    ASAPP.styles.textStyles.body = textStyle
                }
                
                context("with default styles") {
                    it("has a valid snapshot") {
                        let cell = QuickReplyView()
                        cell.frame = CGRect(x: 0, y: 0, width: 320, height: 80)
                        
                        let action = Action(content: nil)!
                        let quickReply = QuickReply(title: "Schedule an appointment to return equipment", action: action, icon: nil)
                        cell.update(for: quickReply, enabled: true)
                        cell.setNeedsLayout()
                        
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a filled bell icon") {
                    it("has a valid snapshot") {
                        let cell = QuickReplyView()
                        cell.frame = CGRect(x: 0, y: 0, width: 320, height: 80)
                        
                        let action = Action(content: nil)!
                        let icon = NotificationIconItem(with: ["name": "bell"])
                        let quickReply = QuickReply(title: "Sc he du le an ap po in tm en t to return equipment", action: action, icon: icon)
                        
                        cell.update(for: quickReply, enabled: true)
                        cell.setNeedsLayout()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a web action") {
                    it("has a valid snapshot") {
                        let cell = QuickReplyView()
                        cell.frame = CGRect(x: 0, y: 0, width: 320, height: 80)
                        
                        let action = WebPageAction(content: [
                            "url": "https://asapp.com/"
                        ])!
                        let quickReply = QuickReply(title: "Schedule an appointment to return equipment", action: action, icon: nil)
                        
                        cell.update(for: quickReply, enabled: true)
                        cell.setNeedsLayout()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a web action and a filled bell icon") {
                    it("has a valid snapshot") {
                        let cell = QuickReplyView()
                        cell.frame = CGRect(x: 0, y: 0, width: 320, height: 80)
                        
                        let action = WebPageAction(content: [
                            "url": "https://asapp.com/"
                        ])!
                        let icon = NotificationIconItem(with: ["name": "bell"])
                        let quickReply = QuickReply(title: "Schedule an appointment to return equipment", action: action, icon: icon)
                        
                        cell.update(for: quickReply, enabled: true)
                        cell.setNeedsLayout()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
                
                context("with a short title and a web action and a filled bell icon") {
                    it("has a valid snapshot") {
                        let cell = QuickReplyView()
                        cell.frame = CGRect(x: 0, y: 0, width: 320, height: 80)
                        
                        let action = WebPageAction(content: [
                            "url": "https://asapp.com/"
                        ])!
                        let icon = NotificationIconItem(with: ["name": "bell"])
                        let quickReply = QuickReply(title: "Appointment", action: action, icon: icon)
                        
                        cell.update(for: quickReply, enabled: true)
                        cell.setNeedsLayout()
                        expect(cell).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
