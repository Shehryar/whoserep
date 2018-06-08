//
//  NotificationBannerSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 2/6/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class NotificationBannerSpec: QuickSpec {
    override func spec() {
        describe("NotificationBanner") {            
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("on its own") {
                let text = "Your payment of $9001 is due in two days. Please pay on time to avoid any late fees."
                var icon: IconItem!
                
                beforeEach {
                    ASAPP.styles = ASAPPStyles()
                    icon = IconItem(style: TestUtil.createStyle(), content: ["icon": ComponentIcon.notificationAlert.rawValue])
                }
                
                context("without an icon or text") {
                    it("has a valid snapshot") {
                        let notification = ChatNotification(title: "Payment Due in 1 Day", text: nil, button: nil, icon: nil)
                        let banner = NotificationBanner(notification: notification)
                        banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                        expect(banner).to(haveValidSnapshot())
                    }
                }
                
                context("without an icon and with text") {
                    it("has a valid snapshot") {
                        let notification = ChatNotification(title: "Payment Due in 1 Day", text: text, button: nil, icon: nil)
                        let banner = NotificationBanner(notification: notification)
                        banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                        expect(banner).to(haveValidSnapshot())
                    }
                }
                
                context("with an icon and without text") {
                    it("has a valid snapshot") {
                        let notification = ChatNotification(title: "Payment Due in 1 Day", text: nil, button: nil, icon: icon)
                        let banner = NotificationBanner(notification: notification)
                        banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                        expect(banner).to(haveValidSnapshot())
                    }
                }
                
                context("with an icon and text") {
                    it("has a valid snapshot") {
                        let notification = ChatNotification(title: "Payment Due in 1 Day", text: text, button: nil, icon: icon)
                        let banner = NotificationBanner(notification: notification)
                        banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                        expect(banner).to(haveValidSnapshot())
                    }
                }
                
                context("expanded with text") {
                    it("has a valid snapshot") {
                        let notification = ChatNotification(title: "Payment Due in 1 Day", text: text, button: nil, icon: icon)
                        let banner = NotificationBanner(notification: notification)
                        banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                        banner.layoutIfNeeded()
                        waitUntil { done in
                            banner.subviews.forEach { subview in
                                if let button = subview as? UIButton {
                                    button.sendActions(for: .touchUpInside)
                                }
                            }
                            banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                            banner.layoutIfNeeded()
                            expect(banner).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
                
                context("expanded with text and a button") {
                    it("has a valid snapshot") {
                        let button = QuickReply(title: "Test", action: WebPageAction(content: ["url": "https://asapp.com/"])!, icon: nil)
                        let notification = ChatNotification(title: "Payment Due in 1 Day", text: text, button: button, icon: icon)
                        let banner = NotificationBanner(notification: notification)
                        banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                        banner.layoutIfNeeded()
                        waitUntil { done in
                            banner.subviews.forEach { subview in
                                if let button = subview as? UIButton {
                                    button.sendActions(for: .touchUpInside)
                                }
                            }
                            banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                            banner.layoutIfNeeded()
                            expect(banner).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
                
                context("expanded with text and a button without a title") {
                    it("has a valid snapshot") {
                        let button = QuickReply(title: "", action: WebPageAction(content: ["url": "https://asapp.com/"])!, icon: nil)
                        let notification = ChatNotification(title: "Payment Due in 1 Day", text: text, button: button, icon: icon)
                        let banner = NotificationBanner(notification: notification)
                        banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                        banner.layoutIfNeeded()
                        waitUntil { done in
                            banner.subviews.forEach { subview in
                                if let button = subview as? UIButton {
                                    button.sendActions(for: .touchUpInside)
                                }
                            }
                            banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                            banner.layoutIfNeeded()
                            expect(banner).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
                
                context("expanded with a button and no text") {
                    it("has a valid snapshot") {
                        let button = QuickReply(title: "Test", action: WebPageAction(content: ["url": "https://asapp.com/"])!, icon: nil)
                        let notification = ChatNotification(title: "Payment Due in 1 Day", text: nil, button: button, icon: icon)
                        let banner = NotificationBanner(notification: notification)
                        banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                        banner.layoutIfNeeded()
                        waitUntil { done in
                            banner.subviews.forEach { subview in
                                if let button = subview as? UIButton {
                                    button.sendActions(for: .touchUpInside)
                                }
                            }
                            banner.frame = CGRect(x: 0, y: 0, width: 320, height: banner.preferredDisplayHeight())
                            banner.layoutIfNeeded()
                            expect(banner).to(haveValidSnapshot())
                            done()
                        }
                    }
                }
            }
        }
    }
}
