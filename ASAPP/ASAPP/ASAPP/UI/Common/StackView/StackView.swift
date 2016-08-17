//
//  StackView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/16/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class StackView: UIView {

    var contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) {
        didSet {
            setNeedsLayout()
        }
    }

    var viewSpacing: CGFloat = 16 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var currentContentHeight: CGFloat {
        var currentContentHeight: CGFloat = 0.0
        for view in arrangedSubviews {
            if !view.hidden && view.alpha > 0 {
                currentContentHeight = max(currentContentHeight, CGRectGetMaxY(view.frame))
            }
        }
        return currentContentHeight > 0 ? currentContentHeight + contentInset.bottom : 0.0
    }
    
    private(set) var arrangedSubviews = [UIView]()
    
    // MARK: Initialization
    
    func commonInit() {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}

// MARK:- Layout

extension StackView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateArrangedSubviewFrames()
    }
    
    /**
     Updates the frames of all arranged subviews and returns the total content height after the updates.
     Can pass updateFrameToFitContentHeight to automatically change the frame's height after updating the frames of subviews.
     */
    func updateArrangedSubviewFrames(updateFrameToFitContent updateFrameToFitContent: Bool = true) -> CGFloat {
        
        func updateFrameWithHeight(height: CGFloat) {
            if updateFrameToFitContent {
                var updatedFrame = frame
                updatedFrame.size.height = height
                frame = updatedFrame
            }
        }
        
        
        let contentWidth = CGRectGetWidth(bounds) - contentInset.left - contentInset.right
        guard contentWidth > 0 else {
            updateFrameWithHeight(0.0)
            return 0.0
        }
        
        var contentTop = contentInset.top
        var contentHeight: CGFloat = 0
        
        for view in arrangedSubviews {
            let viewHeight = ceil(view.sizeThatFits(CGSize(width: contentWidth, height: CGFloat.max)).height)
            view.frame = CGRect(x: contentInset.left, y: contentTop, width: contentWidth, height: viewHeight)
            if !view.hidden && view.alpha > 0 {
                contentTop = CGRectGetMaxY(view.frame) + viewSpacing
                contentHeight = CGRectGetMaxY(view.frame) + contentInset.top
            }
        }
        
        updateFrameWithHeight(contentHeight)
        
        return contentHeight
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        guard size.width > 0 else { return CGSizeZero }
        
        let contentWidth = size.width - contentInset.left - contentInset.right
        var contentHeight = contentInset.top + contentInset.bottom
        
        for (index, view) in arrangedSubviews.enumerate() {
            if !view.hidden && view.alpha > 0 {
                contentHeight += ceil(view.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
                if index < arrangedSubviews.count - 1 {
                    contentHeight += viewSpacing
                }
            }
        }
        
        return CGSize(width: size.width, height: contentHeight)
    }
}

// MARK:- Public Interface

extension StackView {
    func addArrangedView(view: UIView, updateFrameToFitContent: Bool = true) {
        if !subviews.contains(view) {
            addSubview(view)
        }
        arrangedSubviews.append(view)
        updateArrangedSubviewFrames(updateFrameToFitContent: updateFrameToFitContent)
    }
    
    func addArrangedViews(views: [UIView], updateFrameToFitContent: Bool = true) {
        for view in views {
            if !subviews.contains(view) {
                addSubview(view)
            }
            arrangedSubviews.append(view)
        }
        updateArrangedSubviewFrames(updateFrameToFitContent: updateFrameToFitContent)
    }
    
    func removeArrangedView(view: UIView, updateFrameToFitContent: Bool = true) {
        if let index = arrangedSubviews.indexOf(view) {
            arrangedSubviews.removeAtIndex(index)
        }
        
        if subviews.contains(view) {
            view.removeFromSuperview()
            updateArrangedSubviewFrames(updateFrameToFitContent: updateFrameToFitContent)
        }
    }
    
    func removeArrangedViews(views: [UIView], updateFrameToFitContent: Bool = true) {
        var didRemoveView = false
        for view in views {
            if let index = arrangedSubviews.indexOf(view) {
                arrangedSubviews.removeAtIndex(index)
                didRemoveView = true
            }
            if subviews.contains(view) {
                view.removeFromSuperview()
            }
        }
        if didRemoveView {
            updateArrangedSubviewFrames(updateFrameToFitContent: updateFrameToFitContent)
        }
    }
}
