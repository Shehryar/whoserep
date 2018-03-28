//
//  ChatInputViewTestCase.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 3/19/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP
import FBSnapshotTestCase

class ChatInputViewTestCase: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        TestUtil.setUpASAPP()
        
        ASAPP.strings = ASAPPStrings()
        ASAPP.styles = ASAPPStyles()
    }
    
    func testOnItsOwn() {
        let input = ChatInputView()
        input.frame = CGRect(x: 0, y: 0, width: 320, height: 88)
        input.contentInset = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
        input.bubbleInset = UIEdgeInsets(top: 8, left: 20, bottom: 30, right: 20)
        input.displayBorderTop = false
        input.updateDisplay()
        FBSnapshotVerifyView(input, suffixes: NSOrderedSet(array: [""]))
    }
    
    func testInFrontOfAnotherView() {
        let backgroundView = UIView(frame: CGRect(x: 290, y: 0, width: 30, height: 30))
        backgroundView.backgroundColor = UIColor.ASAPP.eggplant
        
        let input = ChatInputView()
        input.frame = CGRect(x: 10, y: 0, width: 320, height: 88)
        input.contentInset = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
        input.bubbleInset = UIEdgeInsets(top: 8, left: 20, bottom: 30, right: 20)
        input.displayBorderTop = false
        input.updateDisplay()
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 88))
        container.backgroundColor = .white
        container.addSubview(backgroundView)
        container.addSubview(input)
        
        usesDrawViewHierarchyInRect = true
        FBSnapshotVerifyView(container, suffixes: NSOrderedSet(array: [""]))
    }
    
    func testInFrontOfAnotherViewWithBlur() {
        let backgroundView = UIView(frame: CGRect(x: 290, y: 0, width: 30, height: 30))
        backgroundView.backgroundColor = UIColor.ASAPP.eggplant
        
        let input = ChatInputView()
        input.frame = CGRect(x: 10, y: 0, width: 320, height: 88)
        input.contentInset = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
        input.bubbleInset = UIEdgeInsets(top: 8, left: 20, bottom: 30, right: 20)
        input.displayBorderTop = false
        input.showBlur()
        input.updateDisplay()
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 88))
        container.backgroundColor = .white
        container.addSubview(backgroundView)
        container.addSubview(input)
        
        usesDrawViewHierarchyInRect = true
        FBSnapshotVerifyView(container, suffixes: NSOrderedSet(array: [""]))
    }
    
    func testWithTheMediaButtonHidden() {
        let input = ChatInputView()
        input.frame = CGRect(x: 0, y: 0, width: 320, height: 88)
        input.contentInset = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
        input.bubbleInset = UIEdgeInsets(top: 8, left: 20, bottom: 30, right: 20)
        input.displayBorderTop = false
        input.textView.text = "The quick brown fox jumps over the lazy dog."
        input.displayMediaButton = false
        input.updateDisplay()
        FBSnapshotVerifyView(input, suffixes: NSOrderedSet(array: [""]))
    }
    
    func testWithIsRoundedTrue() {
        let input = ChatInputView()
        input.frame = CGRect(x: 0, y: 0, width: 320, height: 88)
        input.contentInset = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
        input.bubbleInset = UIEdgeInsets(top: 8, left: 20, bottom: 30, right: 20)
        input.bubbleView.layer.cornerRadius = 20
        input.displayBorderTop = false
        input.isRounded = true
        input.updateDisplay()
        FBSnapshotVerifyView(input, suffixes: NSOrderedSet(array: [""]))
    }
}
