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
    
    // MARK: Initialization
    
    override func commonInit() {
        super.commonInit()
        
        titleView.text = "Rate Your Experience"

        addSubview(ratingView)
    }
}

// MARK:- Layout

extension LeaveFeedbackView {
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect, CGRect) {
        let titleFrame = getTitleViewFrameThatFits(size)
        
        let contentWidth = size.width - contentInset.left - contentInset.right
        let ratingFrame = CGRect(x: contentInset.left, y: titleFrame.maxY + titleMarginBottom,
                                 width: contentWidth, height: 80)
        let inputFrame = CGRect(x: contentInset.left, y: ratingFrame.maxY, width: ratingFrame.width, height: 0)
        
        return (titleFrame, ratingFrame, inputFrame)
    }
    
    override func updateFrames() {
        super.updateFrames()
        
        let (titleFrame, ratingFrame, inputFrame) = getFramesThatFit(bounds.size)
        titleView.frame = titleFrame
        ratingView.frame = ratingFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (_, _, inputFrame) = getFramesThatFit(size)
        
        return CGSize(width: size.width, height: inputFrame.maxY + contentInset.bottom)
    }
}
