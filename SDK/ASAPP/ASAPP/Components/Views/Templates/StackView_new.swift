//
//  StackView_new.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class StackView_new: UIView, ComponentView {

    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            for subview in subviews {
                subview.removeFromSuperview()
            }
            
            if let stackViewItem = stackViewItem {
                for item in stackViewItem.items {
                    if let componentView = ComponentViewFactory.view(withComponent: item) {
                        addSubview(componentView.view)
                    }
                }
            }
            setNeedsLayout()
        }
    }
    
    var stackViewItem: StackViewItem? {
        return component as? StackViewItem
    }

    // MARK: Init
    
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
    
    // MARK: Layout
    
    func getFramesThatFit(_ size: CGSize) -> [CGRect] {
        guard let padding = component?.style.padding else {
            return [CGRect]()
        }
        
        let contentWidth = size.width - padding.left - padding.right
        let contentFrame = CGRect(x: padding.left, y: padding.top,
                                  width: contentWidth, height: 0)
        let frames = ComponentLayoutEngine.getVerticalFrames(for: subviews,
                                                             inside: contentFrame)
        
        return frames
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frames = getFramesThatFit(bounds.size)
        if frames.count == subviews.count {
            for (idx, subview) in subviews.enumerated() {
                subview.frame = frames[idx]
            }
        }
     }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let frames = getFramesThatFit(size)
        
        var maxY: CGFloat = 0
        for frame in frames {
            maxY = max(maxY, frame.maxY)
        }
        if maxY > 0, let padding = component?.style.padding {
            maxY += padding.bottom
        }
        
        return CGSize(width: size.width, height: maxY)
    }
}
