//
//  ChatConnectionStatusViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/16/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ChatConnectionStatusViewSpec: QuickSpec {
    override func spec() {
        describe("ChatConnectionStatusView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
                TestUtil.createStyle()
            }
            
            context("on its own") {
                context("connected") {
                    it("has a valid snapshot") {
                        let view = BannerView(style: .connectionStatus)
                        view.connectionStatus = .connected
                        let size = view.sizeThatFits(CGSize(width: 400, height: CGFloat.greatestFiniteMagnitude))
                        view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("disconnected") {
                    it("has a valid snapshot") {
                        let view = BannerView(style: .connectionStatus)
                        view.connectionStatus = .disconnected
                        let size = view.sizeThatFits(CGSize(width: 400, height: CGFloat.greatestFiniteMagnitude))
                        view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("narrow and disconnected") {
                    it("has a valid snapshot") {
                        let view = BannerView(style: .connectionStatus)
                        view.connectionStatus = .disconnected
                        let size = view.sizeThatFits(CGSize(width: 250, height: CGFloat.greatestFiniteMagnitude))
                        view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        expect(view).to(haveValidSnapshot())
                    }
                }
                
                context("connecting") {
                    it("has a valid snapshot") {
                        let view = BannerView(style: .connectionStatus)
                        view.connectionStatus = .connecting
                        let size = view.sizeThatFits(CGSize(width: 400, height: CGFloat.greatestFiniteMagnitude))
                        view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        expect(view).to(haveValidSnapshot())
                    }
                }
            }
        }
    }
}
