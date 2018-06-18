//
//  ScaleViewSpec.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 4/23/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import Quick
import Nimble
import Nimble_Snapshots

class ScaleViewSpec: QuickSpec {
    override func spec() {
        describe("ScaleView") {
            beforeSuite {
                FBSnapshotTest.setReferenceImagesDirectory(
                    ProcessInfo.processInfo.environment["FB_REFERENCE_IMAGE_DIR"]!)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.rootViewController = UIViewController()
                window.makeKeyAndVisible()
                
                TestUtil.setUpASAPP()
            }
            
            context("on its own") {
                var style: ComponentStyle!
                
                func getView(with style: ComponentStyle, type scaleType: ScaleItem.ScaleType) -> ScaleView {
                    let scaleItem = ScaleItem(style: style, content: ["scaleType": scaleType.rawValue])
                    let scale = ScaleView(frame: CGRect(x: 0, y: 0, width: 375, height: CGFloat.greatestFiniteMagnitude))
                    scale.component = scaleItem
                    let size = scale.sizeThatFits(scale.frame.size)
                    scale.frame = CGRect(x: 0, y: 0, width: scale.frame.width, height: size.height)
                    return scale
                }
                
                beforeEach {
                    style = TestUtil.createStyle()
                }
                
                context("five number") {
                    context("left alignment") {
                        it("has a valid snapshot") {
                            style.alignment = .left
                            let scale = getView(with: style, type: .fiveNumber)
                            expect(scale).to(haveValidSnapshot())
                        }
                    }
                    
                    context("fill alignment") {
                        it("has a valid snapshot") {
                            style.alignment = .fill
                            let scale = getView(with: style, type: .fiveNumber)
                            expect(scale).to(haveValidSnapshot())
                        }
                    }
                }
                
                context("five star") {
                    context("left alignment") {
                        it("has a valid snapshot") {
                            style.alignment = .left
                            let scale = getView(with: style, type: .fiveStar)
                            expect(scale).to(haveValidSnapshot())
                        }
                    }
                    
                    context("fill alignment") {
                        it("has a valid snapshot") {
                            style.alignment = .fill
                            let scale = getView(with: style, type: .fiveStar)
                            expect(scale).to(haveValidSnapshot())
                        }
                    }
                }
            }
        }
    }
}
