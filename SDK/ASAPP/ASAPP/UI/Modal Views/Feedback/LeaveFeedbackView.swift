//
//  LeaveFeedbackView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol LeaveFeedbackViewDelegate: class {
    func leaveFeedbackViewDidChangeContentSize(_ leaveFeedbackView: LeaveFeedbackView)
    func leaveFeedbackViewDidChangeFocus(_ leaveFeedbackView: LeaveFeedbackView, focusedView: UIView?)
}

class LeaveFeedbackView: ModalCardContentView, TextViewAutoExpanding {
    weak var delegate: LeaveFeedbackViewDelegate?
    
    var rating: Int? {
        return ratingView.currentRating
    }
    
    var resolved: Bool? {
        return resolutionView.currentChoice
    }
    
    var feedback: String? {
        return textView.text
    }
    
    // MARK: Layout
    
    var inputHeight: CGFloat = 0
    let inputMaxHeight: CGFloat = 90
    var inputMinHeight: CGFloat = 45
    fileprivate let ratingMarginBottom: CGFloat = 53
    fileprivate let promptMarginBottom: CGFloat = 22
    fileprivate let resolutionMarginBottom: CGFloat = 40
    
    // MARK: UI
    
    fileprivate let ratingView = FeedbackRatingView()
    fileprivate let promptLabel = UILabel()
    fileprivate let resolutionView = YesNoView()
    let textView = UITextView()
    fileprivate let bottomBorder = UIView()
    fileprivate let textViewPlaceholder = UILabel()
    
    // MARK: Initialization
    
    override func commonInit() {
        super.commonInit()
        
        titleView.text = ASAPP.strings.feedbackViewTitle

        addSubview(ratingView)
        
        promptLabel.font = ASAPP.styles.textStyles.body.font
        promptLabel.text = ASAPP.strings.feedbackIssueResolutionPrompt
        promptLabel.textColor = UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 1)
        promptLabel.textAlignment = .center
        addSubview(promptLabel)
        
        addSubview(resolutionView)
        
        let placeholderText = ASAPP.strings.feedbackPrompt
        
        textView.clipsToBounds = true
        textView.backgroundColor = .clear
        textView.font = ASAPP.styles.textStyles.body.font
        textView.textColor = UIColor(red: 0.449, green: 0.457, blue: 0.476, alpha: 1)
        textView.tintColor = ASAPP.styles.colors.buttonPrimary.backgroundNormal
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        textView.delegate = self
        textView.returnKeyType = .send
        textView.isAccessibilityElement = true
        textView.accessibilityTraits = UIAccessibilityTraitSearchField
        textView.accessibilityLabel = placeholderText.trimmingCharacters(in: CharacterSet.punctuationCharacters)
        addSubview(textView)
        textView.sizeToFit()
        inputHeight = textView.frame.size.height
        
        textViewPlaceholder.textColor = textView.textColor!.withAlphaComponent(0.6)
        textViewPlaceholder.font = textView.font
        textViewPlaceholder.text = placeholderText
        textViewPlaceholder.isAccessibilityElement = false
        textView.addSubview(textViewPlaceholder)
        
        bottomBorder.backgroundColor = UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 0.5)
        addSubview(bottomBorder)
        
        updateInputMinHeight()
    }
    
    override func updateFrames() {
        super.updateFrames()
        
        let (titleFrame, ratingFrame, promptFrame, resolutionFrame, textViewPlaceholderFrame, textViewFrame) = getFramesThatFit(bounds.size)
        titleView.frame = titleFrame
        ratingView.frame = ratingFrame
        promptLabel.frame = promptFrame
        resolutionView.frame = resolutionFrame
        textView.frame = textViewFrame
        textViewPlaceholder.frame = textViewPlaceholderFrame
        bottomBorder.frame = CGRect(x: contentInset.left, y: textView.frame.maxY, width: textView.frame.width, height: 1)
    }
}

// MARK:- Layout

extension LeaveFeedbackView {
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect, CGRect, CGRect, CGRect, CGRect) {
        let titleFrame = getTitleViewFrameThatFits(size)
        
        let contentWidth = size.width - contentInset.left - contentInset.right
        
        let ratingHeight = ceil(ratingView.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        let ratingFrame = CGRect(x: contentInset.left, y: titleFrame.maxY + titleMarginBottom,
                                 width: contentWidth, height: ratingHeight)
        
        let promptTop = ratingFrame.maxY + ratingMarginBottom
        let promptHeight = ceil(promptLabel.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        let promptFrame = CGRect(x: contentInset.left, y: promptTop, width: contentWidth, height: promptHeight)
        
        let resolutionTop = promptFrame.maxY + promptMarginBottom
        let resolutionHeight = ceil(resolutionView.sizeThatFits(CGSize(width: contentWidth * 0.666, height: 0)).height)
        let resolutionFrame = CGRect(x: contentInset.left, y: resolutionTop, width: contentWidth, height: resolutionHeight)
        
        let textViewTop = resolutionFrame.maxY + resolutionMarginBottom
        let textViewHeight = inputHeight
        let textViewFrame = CGRect(x: contentInset.left, y: textViewTop, width: contentWidth, height: textViewHeight)
        
        let insets = UIEdgeInsets(
            top: textView.textContainerInset.top,
            left: textView.textContainerInset.left + 5,
            bottom: textView.textContainerInset.bottom,
            right: textView.textContainerInset.right + 5)
        let textViewPlaceholderHeight = ceil(textViewPlaceholder.sizeThatFits(CGSize(width: textViewFrame.width - insets.left - insets.right, height: 0)).height)
        let textViewPlaceholderFrame = CGRect(x: insets.left, y: insets.top, width: textViewFrame.width - insets.left - insets.right, height: textViewPlaceholderHeight)
        
        return (titleFrame, ratingFrame, promptFrame, resolutionFrame, textViewPlaceholderFrame, textViewFrame)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (_, _, _, _, _, textViewFrame) = getFramesThatFit(size)
        
        return CGSize(width: size.width, height: textViewFrame.maxY + contentInset.bottom)
    }
}

// Mark:- UITextViewDelegate

extension LeaveFeedbackView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewPlaceholder.isHidden = true
        
        delegate?.leaveFeedbackViewDidChangeFocus(self, focusedView: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textViewPlaceholder.isHidden = !textView.text.isEmpty
        resizeIfNeeded(true, notifyOfHeightChange: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewPlaceholder.isHidden = !textView.text.isEmpty
        
        delegate?.leaveFeedbackViewDidChangeFocus(self, focusedView: nil)
    }
}

// Mark:- AutoExpandingTextView

extension LeaveFeedbackView {
    func textViewHeightDidChange() {
        delegate?.leaveFeedbackViewDidChangeContentSize(self)
    }
}
