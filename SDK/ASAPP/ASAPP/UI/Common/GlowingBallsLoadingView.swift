//
//  GlowingBallsLoadingView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class GlowingBallsLoadingView: UIView {

    override var tintColor: UIColor! {
        didSet {
            for ballView in ballViews {
                ballView.backgroundColor = tintColor ?? defaultTintColor
            }
        }
    }
    
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) {
        didSet {
            setNeedsLayout()
        }
    }
    
    private(set) var isAnimating = false
    
    private var animationStartTime: TimeInterval = 0
    
    private let ballViews = [UIView(), UIView(), UIView()]
    
    private let ballSize: CGFloat = 6
    
    private let ballMargin: CGFloat = 4
    
    // MARK: Animation Settings
    
    private let alphaDefault: CGFloat = 0.3
    
    private let alphaAnimating: CGFloat = 1.0
    
    private let transformAnimating = CGAffineTransform(translationX: 0, y: -6)
    
    private let animationDelayIncrement: TimeInterval = 0.2
    
    private let animationDurationIn: TimeInterval = 0.2

    private let animationDurationOut: TimeInterval = 0.2
    
    private let defaultTintColor = UIColor(red: 0.682, green: 0.682, blue: 0.682, alpha: 1)
    
    // MARK: Init
    
    func commonInit() {
        for ballView in ballViews {
            ballView.frame = CGRect(x: 0, y: 0, width: ballSize, height: ballSize)
            ballView.layer.cornerRadius = ballSize / 2.0
            ballView.backgroundColor = tintColor ?? defaultTintColor
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

    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentWidth = CGFloat(ballViews.count) * ballSize + CGFloat(ballViews.count - 1) * ballMargin
        var contentLeft = floor((bounds.width - contentWidth) / 2.0)
        for ballView in ballViews {
            let centerX = contentLeft + ballSize / 2.0
            ballView.center = CGPoint(x: centerX, y: bounds.midY)
            contentLeft += ballSize + ballMargin
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let totalWidth = contentInset.left + CGFloat(ballViews.count) * ballSize + CGFloat(ballViews.count - 1) * ballMargin + contentInset.right
        let totalHeight = contentInset.top + ballSize + contentInset.bottom
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    // MARK: Instance Methods
    
    func startAnimating() {
        guard !isAnimating else { return }
        
        isAnimating = true
        let referenceTime = Date.timeIntervalSinceReferenceDate
        self.animationStartTime = referenceTime
        
        beginAnimationCycle(referenceTime: referenceTime)
    }
    
    func stopAnimating() {
        layer.removeAllAnimations()
        
        for ballView in ballViews {
            ballView.layer.removeAllAnimations()
            ballView.transform = .identity
            ballView.alpha = alphaDefault
        }
        
        animationStartTime = 0
        isAnimating = false
    }
    
    // MARK: Private Animation Methods
    
    private func beginAnimationCycle(referenceTime: TimeInterval) {
        guard isAnimating && referenceTime == animationStartTime else {
            return
        }
        
        var delay: TimeInterval = 0.2
        for ballView in ballViews {
            animateBallView(ballView, after: delay, referenceTime: referenceTime, completion: { [weak self] in
                if ballView == self?.ballViews.last {
                    self?.beginAnimationCycle(referenceTime: referenceTime)
                }
            })
            delay += animationDelayIncrement
        }
    }
    
    private func animateBallView(_ view: UIView, after delay: TimeInterval, referenceTime: TimeInterval, completion: (() -> Void)?) {
        guard isAnimating else {
            return
        }
        
        UIView.animate(withDuration: animationDurationIn, delay: delay, options: .curveLinear, animations: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            view.transform = strongSelf.transformAnimating
            view.alpha = strongSelf.alphaAnimating
            
        }, completion: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            UIView.animate(withDuration: strongSelf.animationDurationOut, delay: 0, options: .curveLinear, animations: { [weak self] in
                guard let strongSelf = self,
                    strongSelf.isAnimating && referenceTime == strongSelf.animationStartTime else {
                        return
                }
                
                view.transform = .identity
                view.alpha = strongSelf.alphaDefault
            }, completion: { _ in
                completion?()
            })
        })
    }
}
