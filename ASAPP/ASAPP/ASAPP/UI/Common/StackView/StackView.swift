//
//  StackView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/16/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum StackViewOrientation {
    case Vertical
    case Horizontal
}

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
    
    var orientation: StackViewOrientation = .Vertical {
        didSet {
            if oldValue != orientation {
                setNeedsLayout()
            }
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
    
    func subviewWidthForSize(size: CGSize) -> CGFloat {
        let contentWidth = size.width - contentInset.left - contentInset.right
        
        if orientation == .Horizontal {
            var visibleViewCount: CGFloat = 0.0
            for view in arrangedSubviews {
                if view.hidden || view.alpha == 0 {
                    continue
                }
                visibleViewCount += 1.0
            }
            
            return floor((contentWidth - max(0.0, visibleViewCount - 1) * viewSpacing) / max(1.0, visibleViewCount))
        } else {
            return contentWidth
        }
    }
    
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
        
        var contentHeight: CGFloat = 0
        
        var subviewOrigin = CGPoint(x: contentInset.left, y: contentInset.top)
        let subviewWidth = subviewWidthForSize(bounds.size)
        
        for view in arrangedSubviews {
            let viewHeight = ceil(view.sizeThatFits(CGSize(width: subviewWidth, height: CGFloat.max)).height)
            view.frame = CGRect(origin: subviewOrigin, size: CGSize(width: subviewWidth, height: viewHeight))
            
            if !view.hidden && view.alpha > 0 && viewHeight > 0 {
                if orientation == .Horizontal {
                    subviewOrigin.x = CGRectGetMaxX(view.frame) + viewSpacing
                } else {
                    subviewOrigin.y = CGRectGetMaxY(view.frame) + viewSpacing
                }
                contentHeight = max(contentHeight, CGRectGetMaxY(view.frame) + contentInset.bottom)
            }
        }
        
        updateFrameWithHeight(contentHeight)
        
        return contentHeight
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        guard size.width > 0 else { return CGSizeZero }
        
        let subviewWidth = subviewWidthForSize(size)
        var contentHeight: CGFloat = 0.0
        for (index, view) in arrangedSubviews.enumerate() {
            if !view.hidden && view.alpha > 0 {
                let viewHeight = ceil(view.sizeThatFits(CGSize(width: subviewWidth, height: 0)).height)
                if viewHeight > 0 {
                    if orientation == .Horizontal {
                        contentHeight = max(contentHeight, viewHeight)
                    } else {
                        contentHeight += viewHeight
                        if index < arrangedSubviews.count - 1 {
                            contentHeight += viewSpacing
                        }
                    }
                }
            }
        }
        
        if contentHeight > 0 {
            contentHeight += contentInset.top + contentInset.bottom
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
    
    func clear() {
        removeArrangedViews(arrangedSubviews)
    }
}
