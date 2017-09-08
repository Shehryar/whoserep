//
//  LeaveFeedbackView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class LeaveFeedbackView: ModalCardContentView {
    
    var rating: Int? {
        return ratingView.currentRating
    }
    
    var feedback: String? {
        return textView.text
    }
    
    // MARK: Layout
    
    fileprivate let defaultTextViewHeight: CGFloat = 80.0
    fileprivate let ratingMarginBottom: CGFloat = 24.0
    fileprivate let promptMarginBottom: CGFloat = 20.0
    fileprivate let resolutionMarginBottom: CGFloat = 24.0
    
    // MARK: UI
    
    fileprivate let ratingView = FeedbackRatingView()
    fileprivate let promptLabel = UILabel()
    fileprivate let resolutionView = YesNoView()
    fileprivate let textView = UITextView()
    fileprivate let textViewPlaceholder = UILabel()
    
    // MARK: Initialization
    
    override func commonInit() {
        super.commonInit()
        
        titleView.text = ASAPP.strings.feedbackViewTitle

        addSubview(ratingView)
        
        promptLabel.font = ASAPP.styles.textStyles.body.font
        promptLabel.text = ASAPP.strings.feedbackIssueResolutionPrompt
        promptLabel.textColor = UIColor(red: 0.549, green: 0.557, blue: 0.576, alpha: 1)
        promptLabel.textAlignment = .center
        addSubview(promptLabel)
        
        addSubview(resolutionView)
        
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 6
        textView.backgroundColor = UIColor.white
        textView.font = ASAPP.styles.textStyles.body.font
        textView.textColor = UIColor(red: 0.449, green: 0.457, blue: 0.476, alpha: 1)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.delegate = self
        addSubview(textView)
        
        textViewPlaceholder.textColor = textView.textColor!.withAlphaComponent(0.6)
        textViewPlaceholder.font = textView.font
        textViewPlaceholder.text = ASAPP.strings.feedbackPrompt
        textView.addSubview(textViewPlaceholder)
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
        let textViewHeight = defaultTextViewHeight
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
    
    override func updateFrames() {
        super.updateFrames()
        
        let (titleFrame, ratingFrame, promptFrame, resolutionFrame, textViewPlaceholderFrame, textViewFrame) = getFramesThatFit(bounds.size)
        titleView.frame = titleFrame
        ratingView.frame = ratingFrame
        promptLabel.frame = promptFrame
        resolutionView.frame = resolutionFrame
        textView.frame = textViewFrame
        textViewPlaceholder.frame = textViewPlaceholderFrame
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
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textViewPlaceholder.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewPlaceholder.isHidden = !textView.text.isEmpty
    }
}
