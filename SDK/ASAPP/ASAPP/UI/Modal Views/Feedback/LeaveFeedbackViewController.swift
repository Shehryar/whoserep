//
//  LeaveFeedbackViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol RatingAPIDelegate: class {
    func sendRating(_ rating: Int,
                    resolved: Bool?,
                    forIssueId issueId: Int,
                    withFeedback feedback: String?,
                    completion: @escaping ((_ success: Bool) -> Void)) -> Bool
}

class LeaveFeedbackViewController: ModalCardViewController {

    var issueId: Int?
    
    weak var delegate: RatingAPIDelegate?
    
    // MARK: UI
    
    private let feedbackView = LeaveFeedbackView()
    private var focusedView: UIView?
    
    // MARK: - Init
    
    override func commonInit() {
        super.commonInit()
        
        feedbackView.delegate = self
        
        contentView = feedbackView
        
        successView.text = ASAPP.strings.feedbackSentSuccessMessage
        
        // Controls
        
        controlsView.onConfirmButtonTap = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.isShowingSuccessView {
                strongSelf.dismiss(animated: true, completion: nil)
                return
            }
            
            // Make sure issueId and delegate are set
            guard let issueId = strongSelf.issueId, let delegate = strongSelf.delegate else {
                strongSelf.showErrorMessage("Developer Error: IssueId and Delegate must be set")
                return
            }
            
            // Check for valid input
            guard let rating = strongSelf.feedbackView.rating else {
                    strongSelf.showErrorMessage(ASAPP.strings.feedbackMissingRatingError)
                    return
            }
            let resolved = strongSelf.feedbackView.resolved
            let feedback = strongSelf.feedbackView.feedback
            
            strongSelf.view.endEditing(true)
            strongSelf.showErrorMessage(nil)
            strongSelf.startLoading()
            let canSendMessage = delegate.sendRating(rating, resolved: resolved, forIssueId: issueId, withFeedback: feedback, completion: { (success) in
                if success {
                    strongSelf.stopLoading(hideContentView: true)
                    strongSelf.showSuccessView()
                } else {
                    strongSelf.stopLoading()
                    strongSelf.showErrorMessage(ASAPP.strings.requestErrorGenericFailure)
                }
            })
            
            if !canSendMessage {
                strongSelf.showErrorMessage(ASAPP.strings.requestErrorMessageNoConnection)
            }
        }
    }
    
    override func updateFrames() {
        super.updateFrames()
        
        if let focusedView = focusedView {
            let offsetY = focusedView.frame.origin.y - contentScrollView.bounds.height + focusedView.frame.size.height + feedbackView.contentInset.bottom
            contentScrollView.contentOffset = CGPoint(x: 0, y: offsetY)
        }
    }
    
    func updateFramesAnimated(_ animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.35, animations: { [weak self] in
                self?.updateFrames()
                self?.presentationAnimator.updatePresentedViewFrame(animated: true)
            })
        } else {
            updateFrames()
            presentationAnimator.updatePresentedViewFrame(animated: false)
        }
    }
}

extension LeaveFeedbackViewController: LeaveFeedbackViewDelegate {
    func leaveFeedbackViewDidChangeContentSize(_ leaveFeedbackView: LeaveFeedbackView) {
        updateFramesAnimated()
    }
    
    func leaveFeedbackViewDidChangeFocus(_ leaveFeedbackView: LeaveFeedbackView, focusedView: UIView?) {
        self.focusedView = focusedView
    }
}
