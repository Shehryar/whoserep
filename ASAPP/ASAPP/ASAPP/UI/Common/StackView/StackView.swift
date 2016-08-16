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
        
        updateFrames()
    }
    
    func updateFrames() {
        let contentWidth = CGRectGetWidth(bounds) - contentInset.left - contentInset.right
        guard contentWidth > 0 else {
            return
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
        
        var updatedFrame = frame
        updatedFrame.size.height = contentHeight
        frame = updatedFrame
    }
}

// MARK:- Public Interface

extension StackView {
    func addArrangedView(view: UIView) {
        if !subviews.contains(view) {
            addSubview(view)
        }
        arrangedSubviews.append(view)
        updateFrames()
    }
    
    func addArrangedViews(views: [UIView]) {
        for view in views {
            if !subviews.contains(view) {
                addSubview(view)
            }
            arrangedSubviews.append(view)
        }
        updateFrames()
    }
    
    func removeArrangedView(view: UIView) {
        if let index = arrangedSubviews.indexOf(view) {
            arrangedSubviews.removeAtIndex(index)
        }
        
        if subviews.contains(view) {
            view.removeFromSuperview()
            updateFrames()
        }
    }
    
    func removeArrangedViews(views: [UIView]) {
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
            updateFrames()
        }
    }
}
