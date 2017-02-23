//
//  LeaveFeedbackViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol LeaveFeedbackViewControllerDelegate: class {
    func sendFeedback(rating: Int,
                      feedback: String?,
                      issueId: Int,
                      completion: @escaping ((CreditCardResponse) -> Void)) -> Bool
}

class LeaveFeedbackViewController: ModalCardViewController {

    weak var delegate: LeaveFeedbackViewControllerDelegate?
    
    var issueId: Int?
    
    fileprivate let feedbackView = LeaveFeedbackView()
    
    override func commonInit() {
        super.commonInit()
        
        contentView = feedbackView
        
    }
}
