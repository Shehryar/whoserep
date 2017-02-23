//
//  LeaveFeedbackView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class LeaveFeedbackView: ModalCardContentView {
    
    let ratingView = FeedbackRatingView()
    
    let detailLabel = UILabel()
    
    let textView = UITextView()
    
    fileprivate let defaultTextViewHeight: CGFloat = 80.0
    fileprivate let ratingMarginBottom: CGFloat = 24.0
    fileprivate let detailMarginBottom: CGFloat = 12.0
    
    // MARK: Initialization
    
    override func commonInit() {
        super.commonInit()
        
        titleView.text = "How did we do?"

        addSubview(ratingView)
        
        detailLabel.font = ASAPP.styles.font(for: .modalDetail)
        detailLabel.text = "Leave Feedback (optional)"
        detailLabel.textColor = UIColor(red:0.549, green:0.557, blue:0.576, alpha:1.000)
        detailLabel.textAlignment = .left
        addSubview(detailLabel)
        
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 6
        textView.backgroundColor = UIColor.white
        textView.font = ASAPP.styles.font(for: .modalBody)
        textView.textColor = UIColor(red:0.449, green:0.457, blue:0.476, alpha:1.000)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        addSubview(textView)
    }
}

// MARK:- Layout

extension LeaveFeedbackView {
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect, CGRect, CGRect) {
        let titleFrame = getTitleViewFrameThatFits(size)
        
        let contentWidth = size.width - contentInset.left - contentInset.right
        
        let ratingHeight = ceil(ratingView.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        let ratingFrame = CGRect(x: contentInset.left, y: titleFrame.maxY + titleMarginBottom,
                                 width: contentWidth, height: ratingHeight)
        
        let detailTop = ratingFrame.maxY + ratingMarginBottom
        let detailHeight = ceil(detailLabel.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        let detailFrame = CGRect(x: contentInset.left, y: detailTop, width: contentWidth, height: detailHeight)
        
        let textViewTop = detailFrame.maxY + detailMarginBottom
        let textViewHeight = defaultTextViewHeight
        let textViewFrame = CGRect(x: contentInset.left, y: textViewTop, width: contentWidth, height: textViewHeight)
        
        return (titleFrame, ratingFrame, detailFrame, textViewFrame)
    }
    
    override func updateFrames() {
        super.updateFrames()
        
        let (titleFrame, ratingFrame, detailFrame, textViewFrame) = getFramesThatFit(bounds.size)
        titleView.frame = titleFrame
        ratingView.frame = ratingFrame
        detailLabel.frame = detailFrame
        textView.frame = textViewFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (_, _, _, textViewFrame) = getFramesThatFit(size)
        
        return CGSize(width: size.width, height: textViewFrame.maxY + contentInset.bottom)
    }
}
