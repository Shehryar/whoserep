//
//  TooltipView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 11/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class TooltipView: UIView {
    
    enum ArrowSide {
        case top
    }
    
    // MARK: Properties
    
    let text: String
    
    let styles: ASAPPStyles
    
    var maxTooltipWidth: CGFloat = 260 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var textInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var arrowSide: ArrowSide = .top {
        didSet {
            switch arrowSide {
            case .top:
                arrowView.direction = .up
                break
            }
            
            setNeedsLayout()
        }
    }
    
    var arrowCenterOffset: CGFloat? {
        didSet {
            setNeedsLayout()
        }
    }
    
    var arrowHeight: CGFloat = 6 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var cornerRadius: CGFloat = 6 {
        didSet {
            bubbleView.layer.cornerRadius = cornerRadius
            setNeedsLayout()
        }
    }
    
    fileprivate let arrowView = TriangleView()
    
    fileprivate let bubbleView = UIView()
    
    fileprivate let label = UILabel()
    
    // MARK: Initialization
    
    required init(text: String, styles: ASAPPStyles) {
        self.text = text
        self.styles = styles
        super.init(frame: .zero)
        
        let fillColor = UIColor.black.withAlphaComponent(0.9)
        arrowView.fillColor = fillColor
        addSubview(arrowView)
        
        bubbleView.backgroundColor = fillColor
        bubbleView.layer.cornerRadius = cornerRadius
        addSubview(bubbleView)
        
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        label.font = styles.font(for: .tooltip)
        label.textColor = UIColor.white
        bubbleView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Layout
    
    func framesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        let maxWidth = min(maxTooltipWidth, size.width)
        
        let maxLabelWidth = maxWidth - textInset.left - textInset.right
        let labelSize = label.sizeThatFits(CGSize(width: maxLabelWidth, height: 0))
        
        let bubbleWidth = ceil(labelSize.width + textInset.left + textInset.right)
        let bubbleHeight = ceil(labelSize.height + textInset.top + textInset.bottom)
        
        let bubbleFrame = CGRect(x: 0, y: arrowHeight, width: bubbleWidth, height: bubbleHeight)
        
        let arrowWidth = arrowHeight * 2.0
        let arrowFrame: CGRect
        switch arrowSide {
        case .top:
            var x: CGFloat = bubbleWidth - arrowWidth / 2.0
            if let arrowCenterOffset = arrowCenterOffset {
                x = max(cornerRadius, min(size.width - arrowWidth - cornerRadius, arrowCenterOffset - arrowWidth / 2.0))
            }
            arrowFrame = CGRect(x: x, y: 0, width: arrowWidth, height: arrowHeight)
        }
        
        return (bubbleFrame, arrowFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (bubbleFrame, arrowFrame) = framesThatFit(bounds.size)
        bubbleView.frame = bubbleFrame
        arrowView.frame = arrowFrame
        label.frame = UIEdgeInsetsInsetRect(bubbleView.bounds, textInset)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (bubbleFrame, arrowFrame) = framesThatFit(size)
        
        let width = max(bubbleFrame.maxX, arrowFrame.maxX)
        let height = max(bubbleFrame.maxY, arrowFrame.maxY)
        
        return CGSize(width: width, height: height)
    }
}

// MARK:- Showing

extension TooltipView {
    
    class func showTooltip(withText text: String,
                           styles: ASAPPStyles,
                           targetView: UIView,
                           parentView: UIView,
                           onDismiss: (() -> Void)?) -> TooltipPresenter? {
        
        let tooltip = TooltipView(text: text, styles: styles)
        
        let tooltipPresenter = TooltipPresenter(withTooltip: tooltip)
        tooltipPresenter.onDismiss = onDismiss
        tooltipPresenter.show(withTargetView: targetView, in: parentView)
        
        return tooltipPresenter
    }
    
    class func showTooltip(withText text: String,
                           styles: ASAPPStyles,
                           targetBarButtonItem: UIBarButtonItem,
                           parentView: UIView,
                           onDismiss: (() -> Void)?) -> TooltipPresenter?  {
        guard let targetView = targetBarButtonItem.customView ??
            targetBarButtonItem.value(forKey: "view") as? UIView
            else {
                return nil
        }
        
        return showTooltip(withText: text,
                           styles: styles,
                           targetView: targetView,
                           parentView: parentView,
                           onDismiss: onDismiss)
    }
}

