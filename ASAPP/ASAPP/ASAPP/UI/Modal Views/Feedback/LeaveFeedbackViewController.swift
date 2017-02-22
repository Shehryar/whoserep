//
//  LeaveFeedbackViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class LeaveFeedbackViewController: ModalCardViewController {

    fileprivate let feedbackView = LeaveFeedbackView()
    
    override func commonInit() {
        super.commonInit()
        
        contentView = feedbackView
    }
}
