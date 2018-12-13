//
//  FeedbackForm.swift
//  Tests
//
//  Created by Shehryar Hussain on 11/27/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP

class FeedbackForm: ComponentViewController {
    var keyboardObserver: KeyboardObserver?
    var keyboardHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let json = TestUtil.dictForFile(named: "feedback-form-test")
        componentViewContainer = ComponentViewContainer.from(json)
        keyboardObserver = KeyboardObserver()
        keyboardObserver?.delegate = self
        keyboardObserver?.registerForNotifications()
        delegate = self
    }
}

extension FeedbackForm: ComponentViewControllerDelegate {
    func componentViewController(_ viewController: ComponentViewController, didTapAPIAction action: APIAction, withFormData formData: [String: Any]?, completion: @escaping APIActionResponseHandler) {
        return
    }
    
    func componentViewController(_ viewController: ComponentViewController, didTapHTTPAction action: HTTPAction, withFormData formData: [String: Any]?, completion: @escaping APIActionResponseHandler) {
        return
    }
    
    func componentViewController(_ viewController: ComponentViewController, fetchContentForViewNamed viewName: String, withData data: [String: Any]?, completion: @escaping ((ComponentViewContainer?, String?) -> Void)) {
        return
    }
    
    func componentViewControllerDidFinish(with action: FinishAction?, container: ComponentViewContainer?) {
        return
    }
}

extension FeedbackForm: IdentifiableTestCase {
    static var testCaseIdentifier = "feedbackForm"
}

extension FeedbackForm: KeyboardObserverDelegate {
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat, withDuration duration: TimeInterval, animationCurve: UIViewAnimationOptions) {
        guard height != keyboardHeight else {
            return
        }
        
        keyboardHeight = height
        let viewController = self
        if let view = view {
            let newHeight = viewController.originalBounds.height - keyboardHeight
            viewController.willUpdateFrames()
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: animationCurve,
                animations: {
                    
                    viewController.updateFrames()
                    var frame = view.frame
                    frame.size.height = newHeight
                    view.frame = frame
                    view.layoutIfNeeded()
                    
                    viewController.didUpdateFrames()
            })
        }
    }
}
