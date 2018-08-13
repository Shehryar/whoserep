//
//  ScrollView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ScrollView: UIScrollView, ComponentView {

    // MARK: Properties
    
    private(set) var contentView: ComponentView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            
            contentView?.interactionHandler = interactionHandler
            contentView?.contentHandler = contentHandler
            if let contentView = contentView {
                addSubview(contentView.view)
                accessibilityElements = [contentView]
                setNeedsLayout()
            }
        }
    }
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            contentView = scrollViewItem?.root.createView()
        }
    }
    
    var nestedComponentViews: [ComponentView]? {
        if let contentView = contentView {
            return [contentView]
        }
        return nil
    }
    
    var scrollViewItem: ScrollViewItem? {
        return component as? ScrollViewItem
    }
    
    var interactionHandler: InteractionHandler? {
        didSet {
            updateHandlersForNestedComponentViews()
        }
    }
    
    var contentHandler: ComponentViewContentHandler? {
        didSet {
            updateHandlersForNestedComponentViews()
        }
    }
    
    private var previousOffset = CGPoint.zero
    private var previousFrame = CGRect.zero
    
    // MARK: Init
    
    func commonInit() {
        isAccessibilityElement = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Layout
    
    func getContentViewFrameThatFits(_ size: CGSize) -> CGRect {
        guard let contentView = contentView else {
            return .zero
        }
        
        var fitContentToSize = size
        
        if let stackViewItem = contentView.component as? StackViewItem {
            if stackViewItem.orientation == .vertical {
                fitContentToSize.width = min(fitContentToSize.width, UIScreen.main.bounds.width)
                fitContentToSize.height = 0
            } else {
                fitContentToSize.width = 0
                fitContentToSize.height = min(fitContentToSize.height, UIScreen.main.bounds.height)
            }
        }
        
        let contentSize = contentView.view.sizeThatFits(fitContentToSize)
        
        return CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
    }
    
    private func isNearBottom() -> Bool {
        return contentSize.height - contentOffset.y - frame.height < 100
    }
    
    func willUpdateFrames() {
        if isNearBottom() {
            previousOffset = contentOffset
            previousFrame = frame
        } else {
            previousOffset = .zero
            previousFrame = .zero
        }
    }
    
    func updateFrames() {
        let contentFrame = getContentViewFrameThatFits(bounds.size)
        contentView?.view.frame = contentFrame
        contentView?.updateFrames()
        contentSize = contentFrame.size
    }
    
    func didUpdateFrames() {
        if frame.height != previousFrame.height {
            let difference = previousFrame.height - frame.height
            setContentOffset(CGPoint(x: previousOffset.x, y: max(0, previousOffset.y + difference)), animated: false)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var fitToSize = size
        if fitToSize.width == 0 {
            DebugLog.w(caller: self, "Should specify bounded size when sizing. (used = \(size))")
            fitToSize.width = UIScreen.main.bounds.width
        }
        if fitToSize.height == 0 {
            DebugLog.w(caller: self, "Should specify bounded size when sizing. (used = \(size))")
            fitToSize.height = UIScreen.main.bounds.height
        }
        
        let contentFrame = getContentViewFrameThatFits(fitToSize)
        
        return CGSize(width: min(fitToSize.width, contentFrame.width),
                      height: min(fitToSize.height, contentFrame.height))
    }

}
