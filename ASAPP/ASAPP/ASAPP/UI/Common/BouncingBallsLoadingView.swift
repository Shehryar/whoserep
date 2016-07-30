//
//  BouncingBallsLoadingView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SnapKit

class BouncingBallsLoadingView: UIView {

    override var tintColor: UIColor! {
        didSet {
            for ballView in ballViews {
                ballView.backgroundColor = tintColor ?? Colors.grayColor()
            }
        }
    }
    
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 12, right: 16) {
        didSet {
            setNeedsLayout()
            setNeedsUpdateConstraints()
        }
    }
    
    private(set) var animating = false
    
    private var animationStartTime: NSTimeInterval = 0
    
    private let ballViews = [UIView(), UIView(), UIView()]
    
    private let ballSize: CGFloat = 8
    
    private let ballMargin: CGFloat = 6
    
    private let ballBounceDistance: CGFloat = 10
    
    // MARK: Init
    
    func commonInit() {
        updateBalls()
        for ballView in ballViews {
            addSubview(ballView)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Appearance
    
    func updateBalls() {
        for ballView in ballViews {
            ballView.frame = CGRect(x: 0, y: 0, width: ballSize, height: ballSize)
            ballView.layer.cornerRadius = ballSize / 2.0
            ballView.backgroundColor = tintColor ?? Colors.grayColor()
        }
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !animating {
            let contentWidth = CGFloat(ballViews.count) * ballSize + CGFloat(ballViews.count - 1) * ballMargin
            var contentLeft = floor((CGRectGetWidth(bounds) - contentWidth) / 2.0)
            let centerY = CGRectGetHeight(bounds) - contentInset.bottom - ballSize / 2.0
            for ballView in ballViews {
                let centerX = contentLeft + ballSize / 2.0
                ballView.center = CGPoint(x: centerX, y: centerY)
                contentLeft = CGRectGetMaxX(ballView.frame) + ballMargin
            }
        }
    }
    
    // MARK: Instance Methods
    
    func beginAnimating() {
        guard !animating else { return }
        
        layoutSubviews()
        
        animating = true
        animationStartTime = NSDate().timeIntervalSinceNow
        let blockAnimationStartTime = animationStartTime
        
        var delay = 0.4
        for ballView in ballViews {
            animateBallView(ballView, delay: delay, completion: {
                if ballView == self.ballViews.last {
                    Dispatcher.delay(300) {
                        
                        if self.animating && self.animationStartTime == blockAnimationStartTime {
                            self.animating = false
                            self.beginAnimating()
                        }
                    }
                }
            })
            delay += 0.14
        }
    }
    
    func endAnimating() {
        layer.removeAllAnimations()
        animating = false
        setNeedsLayout()
    }
    
    // MARK: Utility
    
    private func centerYDefault() -> CGFloat {
        return CGRectGetHeight(bounds) - contentInset.bottom - ballSize / 2.0
    }
    
    private func centerYUp() -> CGFloat {
        return centerYDefault() - ballBounceDistance
    }
    
    private func animateBallView(ballView: UIView, delay: Double, completion: (() -> Void)?) {
        animateUp(ballView, withDelay: delay, completion: {
            self.animateDown(ballView, withDelay: 0, completion: completion)
        })
    }
    
    private func animateUp(ballView: UIView, withDelay delay: Double, completion: (() -> Void)?) {
        UIView.animateWithDuration(0.24, delay: delay, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: {
            ballView.center = CGPoint(x: ballView.center.x, y: self.centerYUp())
            }) { (completed) in
                completion?()
        }
    }
    
    private func animateDown(ballView: UIView, withDelay delay: Double, completion: (() -> Void)?) {
        UIView.animateWithDuration(0.20, delay: delay, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: {
            ballView.center = CGPoint(x: ballView.center.x, y: self.centerYDefault())
        }) { (completed) in
            completion?()
        }
    }

    
    // MARK: AutoLayout
    
    override func updateConstraints() {
        let totalWidth = contentInset.left + CGFloat(ballViews.count) * ballSize + CGFloat(ballViews.count - 1) * ballMargin + contentInset.right
        let totalHeight = contentInset.top + ballSize + ballBounceDistance + contentInset.bottom
        
        self.snp_updateConstraints { (make) in
            make.width.equalTo(totalWidth)
            make.height.equalTo(totalHeight)
        }
        super.updateConstraints()
    }
}
