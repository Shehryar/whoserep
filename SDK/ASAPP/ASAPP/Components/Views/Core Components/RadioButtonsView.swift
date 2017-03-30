//
//  RadioButtonsView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonsView: BaseComponentView {
    
    // MARK: Properties
    
    var buttonViews = [RadioButtonView]()
    
    fileprivate(set) var selectedItem: RadioButtonItem? {
        didSet {
            if selectedItem == oldValue {
                return
            }
            radioButtonsItem?.value = selectedItem?.value
            for buttonView in buttonViews {
                buttonView.isSelected = buttonView.component == selectedItem
            }
        }
    }
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            if let radioButtonsItem = radioButtonsItem {
                setButtonViewsCount(to: radioButtonsItem.buttons.count)
                
                for (idx, buttonItem) in radioButtonsItem.buttons.enumerated() {
                    buttonViews[idx].component = buttonItem
                }
                setNeedsLayout()
            }
        }
    }
    
    var radioButtonsItem: RadioButtonsItem? {
        return component as? RadioButtonsItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
    
        
    }
    
    // MARK: Utility
    
    func setButtonViewsCount(to count: Int) {
        for buttonView in buttonViews {
            buttonView.removeFromSuperview()
        }

        let countDifference = buttonViews.count - count
        if countDifference > 0 {
            buttonViews.removeLast(countDifference)
        } else {
            while buttonViews.count < count {
                var buttonView = RadioButtonView()
                buttonView.onTap = { [weak self] (currentItem) in
                    self?.selectedItem = currentItem
                }
                buttonViews.append(buttonView)
            }
        }
        
        for buttonView in buttonViews {
            addSubview(buttonView)
        }
    }
    
    // MARK: Layout
    
    func getFramesThatFit(_ size: CGSize) -> ([CGRect], CGSize) {
        var frames = [CGRect]()
        for _ in buttonViews {
            frames.append(.zero)
        }
        
        guard let item = radioButtonsItem else {
            return (frames, .zero)
        }
        
        let (maxContentSize, inset) = ComponentLayoutEngine.getMaxContentSizeThatFits(size, with: item.style)
        guard maxContentSize.width > 0 && maxContentSize.height > 0 else {
            return (frames, .zero)
        }
        
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        
        var top = inset.top
        for (idx, buttonView) in buttonViews.enumerated() {
            let margin = buttonView.component?.style.margin ?? .zero
            let buttonWidth = maxContentSize.width - margin.left - margin.right
            let buttonSize = buttonView.sizeThatFits(CGSize(width: buttonWidth, height: 0))
            
            top += margin.top
            let frame = CGRect(x: inset.left, y: top,
                               width: buttonWidth, // buttonSize.width
                               height: ceil(buttonSize.height))
            frames[idx] = frame
            top += frame.height + margin.bottom
            
            maxX = max(maxX, frames[idx].maxX + margin.right)
            maxY = max(maxY, top)
        }
        
        let contentSize: CGSize
        if maxX > 0 && maxY > 0 {
            contentSize = CGSize(width: maxX + inset.right,
                                 height: maxY + inset.bottom)
        } else {
            contentSize = .zero
        }
        
        return (frames, contentSize)
    }
    
    override func updateFrames() {
        let (frames, _) = getFramesThatFit(bounds.size)
        for (idx, buttonView) in buttonViews.enumerated() {
            buttonView.frame = frames[idx]
            buttonView.updateFrames()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let radioButtonsItem = radioButtonsItem else {
            return .zero
        }
        let (_, contentSize) = getFramesThatFit(size)

        return contentSize
    }
}
