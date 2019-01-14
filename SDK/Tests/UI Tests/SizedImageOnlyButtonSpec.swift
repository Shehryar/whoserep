//
//  SizedImageOnlyButtonSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 12/24/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class SizedImageOnlyButtonSpec: QuickSpec {
    override func spec() {
        let stableImageURL = "https://s3.amazonaws.com/asapp-chat-sdk-historical-releases/fixtures/stable-image.jpg"
        let timeout: TimeInterval = 5
        
        describe("SizedImageOnlyButton") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
                TestUtil.createStyle()
                
                let dummy = UIImageView(frame: CGRect(x: 0, y: 0, width: 260, height: 260))
                waitUntil(timeout: timeout) { done in
                    dummy.sd_setImage(with: URL(string: stableImageURL)!) { _, _, _, _ in
                        done()
                    }
                }
            }
            
            context("on its own") {
                context("with default styles") {
                    it("has a valid snapshot") {
                        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
                        button.sd_setBackgroundImage(with: URL(string: stableImageURL)!, for: .normal)
                        button.setAttributedTitle(NSAttributedString(string: "Attributed Testing"), for: .normal)
                        button.addTarget(self, action: #selector(self.noop), for: .touchUpInside)
                        let targets = button.allTargets
                        let sioButton = SizedImageOnlyButton(button: button)
                        sioButton.imageSize = CGSize(width: 20, height: 20)
                        sioButton.sizeToFit()
                        expect(sioButton).to(haveValidSnapshot())
                        expect(sioButton.allTargets).to(equal(targets))
                    }
                }
            }
        }
    }
    
    @objc func noop() {}
}
