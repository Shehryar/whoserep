//
//  RestartConfirmationActionSheetTestCase.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 3/14/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import FBSnapshotTestCase

class RestartConfirmationActionSheetTestCase: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        TestUtil.setUpASAPP()
    }
    
    func testOnItsOwn() {
        let actionSheet = RestartConfirmationActionSheet()
        actionSheet.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
        
        usesDrawViewHierarchyInRect = true
        FBSnapshotVerifyView(actionSheet, suffixes: NSOrderedSet(array: [""]))
    }
    
    func testInFrontOfAnotherView() {
        let backgroundView = UIView(frame: CGRect(x: 100, y: 100, width: 50, height: 300))
        backgroundView.backgroundColor = UIColor.ASAPP.eggplant
        
        let actionSheet = RestartConfirmationActionSheet()
        actionSheet.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
        
        let container = UIView(frame: actionSheet.bounds)
        container.backgroundColor = .white
        container.addSubview(backgroundView)
        container.addSubview(actionSheet)
        
        usesDrawViewHierarchyInRect = true
        FBSnapshotVerifyView(container, suffixes: NSOrderedSet(array: [""]))
    }
}
