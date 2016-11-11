//
//  TooltipPresenter.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 11/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class TooltipPresenter: NSObject {

    let tooltipView: TooltipView
    
    let tappableView = UIView()
    
    var onDismiss: (() -> Void)?
    
    required init(withTooltip tooltip: TooltipView) {
        self.tooltipView = tooltip
        super.init()
        
        tooltipView.alpha = 0.0
        
        tappableView.backgroundColor = UIColor.clear
        tappableView.isUserInteractionEnabled = true
        tappableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TooltipPresenter.dismiss)))
        tappableView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(TooltipPresenter.dismiss)))
        tappableView.addSubview(tooltipView)
    }
}

// MARK:- Presentation

extension TooltipPresenter {
    
    func show(withTargetView targetView: UIView, in parentView: UIView) {
        if tappableView.superview != nil {
            tappableView.removeFromSuperview()
        }
        
        updateFramesForPresentation(withTargetView: targetView, in: parentView)
        tooltipView.alpha = 0.0
        
        let animationEndCenter = tooltipView.center
        let animationStartCenter = CGPoint(x: animationEndCenter.x,
                                           y: animationEndCenter.y + 5)
        tooltipView.center = animationStartCenter
        parentView.addSubview(tappableView)
        
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.tooltipView.alpha = 1.0
            self?.tooltipView.center = animationEndCenter
        })
    }
}

// MARK:- Dismissal

extension TooltipPresenter {
    
    func dismiss() {
        dismissAnimated(true)
    }
    
    func dismissAnimated(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                guard let tooltip = self?.tooltipView else { return }
                
                let animationEndCenter = CGPoint(x: tooltip.center.x, y: tooltip.center.y + 10)
                tooltip.center = animationEndCenter
                tooltip.alpha = 0.0
                
                }, completion: { [weak self] (completed) in
                    self?.tappableView.removeFromSuperview()
                    self?.onDismiss?()
            })
        } else {
            tooltipView.alpha = 0.0
            tappableView.removeFromSuperview()
            onDismiss?()
        }
    }
}

// MARK:- Layout

extension TooltipPresenter {
    
    func updateFramesForPresentation(withTargetView targetView: UIView, in parentView: UIView) {
        guard let targetSuperview = targetView.superview else {
            DebugLog("No superview found for targetView")
            return
        }
        
        let targetFrame = targetSuperview.convert(targetView.frame, to: parentView)
        updateFramesForPresentation(withTargetFrame: targetFrame, in: parentView.bounds)
    }
    
    func updateFramesForPresentation(withTargetFrame targetFrame: CGRect, in containerFrame: CGRect) {
        tappableView.frame = containerFrame
        
        // Assumes positioned below targetView
        
        let minSidePadding: CGFloat = 8
        
        let ttTop = targetFrame.maxY + 5
        var arrowOffset: CGFloat?
        let ttSize = tooltipView.sizeThatFits(containerFrame.size)
        let ttHalfWidth = ceil(ttSize.width / 2.0)
        
        let shouldLeftAlign = targetFrame.midX - ttHalfWidth < minSidePadding
        let shouldRightAlign = containerFrame.width - minSidePadding - ttHalfWidth < targetFrame.midX
        let shouldCenter = ttSize.width < targetFrame.width || (!shouldLeftAlign && !shouldRightAlign)
        
        let ttLeft: CGFloat
        if shouldCenter {
            ttLeft = floor(targetFrame.midX - ttSize.width / 2.0)
        } else if shouldLeftAlign {
            ttLeft = targetFrame.minX
            arrowOffset = targetFrame.width / 2.0
        } else {
            ttLeft = targetFrame.maxX - ttSize.width
            arrowOffset = ttSize.width - targetFrame.width / 2.0
        }
        if let arrowOffset = arrowOffset {
            tooltipView.arrowCenterOffset = arrowOffset
        } else {
            tooltipView.arrowCenterOffset = nil
        }
        tooltipView.frame = CGRect(x: ttLeft, y: ttTop, width: ttSize.width, height: ttSize.height)
    }
}
