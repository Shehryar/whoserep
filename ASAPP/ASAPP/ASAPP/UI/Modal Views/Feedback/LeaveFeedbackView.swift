//
//  LeaveFeedbackView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class LeaveFeedbackView: ModalCardContentView {
    
    // MARK: Initialization
    
    override func commonInit() {
        super.commonInit()
        
        titleView.text = "Leave Feedback"
        titleView.image = Images.asappImage(.iconErrorAlertFilled)
    }
}

// MARK:- Layout

extension LeaveFeedbackView {
    override func updateFrames() {
        super.updateFrames()
    }
//    
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        return CGSize(width: size.width, height: 200)
//    }
}
