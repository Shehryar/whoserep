//
//  NavBarButtonItemSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/23/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class NavBarButtonItemSpec: QuickSpec {
    override func spec() {
        describe("NavBarButtonItem") {
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
            
            context("with the bubble style") {
                var toolbar: UIToolbar!
                
                beforeEach {
                    toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 64))
                    toolbar.backgroundColor = .gray
                    ASAPP.strings = ASAPPStrings()
                    ASAPP.styles = ASAPPStyles()
                    ASAPP.styles.navBarStyles.buttonStyle = .bubble
                }
                
                context("in the predictive view on the left with a title and with default styles") {
                    it("has a valid snapshot") {
                        let button = NavBarButtonItem(location: .predictive, side: .left)
                        button.configTitle("Button Title")
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
                
                context("in the predictive view on the right with a title and with default styles") {
                    it("has a valid snapshot") {
                        let button = NavBarButtonItem(location: .predictive, side: .right)
                        button.configTitle("Button Title")
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
                
                context("in the chat view on the left with a title and with default styles") {
                    it("has a valid snapshot") {
                        let button = NavBarButtonItem(location: .chat, side: .left)
                        button.configTitle("Button Title")
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
                
                context("in the chat view on the right with a title and with default styles") {
                    it("has a valid snapshot") {
                        let button = NavBarButtonItem(location: .chat, side: .right)
                        button.configTitle("Button Title")
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
                
                context("in the predictive view on the left with an image") {
                    it("has a valid snapshot") {
                        let button = NavBarButtonItem(location: .predictive, side: .left)
                        let navBarButtonImage = ASAPPNavBarButtonImage(image: Images.getImage(Images.Icon.iconErrorAlert)!, size: CGSize(width: 18, height: 16))
                        button.configImage(navBarButtonImage)
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
                
                context("in the predictive view on the left with a title and an image") {
                    it("has a valid snapshot") {
                        let button = NavBarButtonItem(location: .predictive, side: .left)
                        let navBarButtonImage = ASAPPNavBarButtonImage(image: Images.getImage(Images.Icon.iconErrorAlert)!, size: CGSize(width: 18, height: 16))
                        button.configTitle("Test")
                        button.configImage(navBarButtonImage)
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
            }
            
            context("with the text style") {
                var toolbar: UIToolbar!
                
                beforeEach {
                    toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 64))
                    toolbar.backgroundColor = .gray
                    ASAPP.strings = ASAPPStrings()
                    ASAPP.styles = ASAPPStyles()
                    ASAPP.styles.navBarStyles.buttonStyle = .text
                }
                
                context("in the predictive view on the left with a title and with default styles") {
                    it("has a valid snapshot") {
                        let button = NavBarButtonItem(location: .predictive, side: .left)
                        button.configTitle("Button Title")
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
                
                context("in the predictive view on the right with a title and with default styles") {
                    it("has a valid snapshot") {
                        let button = NavBarButtonItem(location: .predictive, side: .right)
                        button.configTitle("Button Title")
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
                
                context("in the chat view on the left with a title and with default styles") {
                    it("has a valid snapshot") {
                        let button = NavBarButtonItem(location: .chat, side: .left)
                        button.configTitle("Button Title")
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
                
                context("in the chat view on the right with a title and with default styles") {
                    it("has a valid snapshot") {
                        let button = NavBarButtonItem(location: .chat, side: .right)
                        button.configTitle("Button Title")
                        toolbar.items = [button]
                        expect(toolbar).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
