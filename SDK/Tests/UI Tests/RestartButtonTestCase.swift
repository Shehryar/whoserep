//
//  RestartButtonTestCase.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 3/13/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import FBSnapshotTestCase

class RestartButtonTestCase: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        TestUtil.setUpASAPP()
    }
    
    func testOnItsOwn() {
        let button = RestartButton(frame: .zero)
        button.frame = CGRect(x: 0, y: 0, width: 320, height: button.defaultHeight)
        FBSnapshotVerifyView(button, suffixes: NSOrderedSet(array: [""]))
    }
    
    func testInFrontOfAnotherView() {
        let backgroundView = UIView(frame: CGRect(x: 250, y: 10, width: 30, height: 30))
        backgroundView.backgroundColor = UIColor.ASAPP.eggplant
        
        let button = RestartButton(frame: .zero)
        button.frame = CGRect(x: 0, y: 0, width: 320, height: button.defaultHeight)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: button.defaultHeight))
        container.backgroundColor = .white
        container.addSubview(backgroundView)
        container.addSubview(button)
        
        usesDrawViewHierarchyInRect = true
        FBSnapshotVerifyView(container, suffixes: NSOrderedSet(array: [""]))
    }
}
