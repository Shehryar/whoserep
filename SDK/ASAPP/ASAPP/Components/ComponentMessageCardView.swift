//
//  ComponentMessageCardView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/18/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class ComponentMessageCardView: ComponentCardView, MessageBubbleCornerRadiusUpdating {
    private var shimmerLayer: CALayer?
    private let shimmerWidth: CGFloat = 70
    private var shimmerStart: CGPoint = .zero
    private var shimmerEnd: CGPoint = .zero
    private var shimmerKey = "shimmer"
    private var isAnimating = false
    
    var shouldAnimate = false {
        didSet {
            if shouldAnimate {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
    
    var message: ChatMessage? {
        didSet {
            updateRoundedCorners()
        }
    }
    
    var messagePosition: MessageListPosition = .none {
        didSet {
            updateRoundedCorners()
        }
    }
    
    override func commonInit() {
        super.commonInit()
    }
    
    override func updateRoundedCorners() {
        if let message = message {
            roundedCorners = getBubbleCorners(for: message, isAttachment: true)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shimmerLayer == nil {
            let frame = CGRect(x: -shimmerWidth, y: 0, width: shimmerWidth, height: componentView?.view.frame.height ?? 0)
            let newLayer = createGradient(frame: frame)
            shimmerStart = newLayer.position
            shimmerEnd = CGPoint(x: -shimmerStart.x + (componentView?.view.frame.width ?? 0), y: shimmerStart.y)
            layer.addSublayer(newLayer)
            shimmerLayer = newLayer
            
            if isAnimating {
                startAnimating()
            }
        }
    }
    
    private func startAnimating() {
        isAnimating = true
        
        guard let shimmerLayer = shimmerLayer else {
            return
        }
        
        let translate = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        translate.fromValue = shimmerStart
        translate.toValue = shimmerEnd
        translate.duration = 2.9
        translate.isRemovedOnCompletion = false
        translate.repeatCount = .infinity
        
        shimmerLayer.add(translate, forKey: shimmerKey)
    }
    
    private func stopAnimating() {
        shimmerLayer?.removeAnimation(forKey: shimmerKey)
        isAnimating = false
    }
    
    private func createGradient(frame: CGRect) -> CALayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        let clearWhite = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        gradient.colors = [clearWhite.cgColor, fillColor.withAlphaComponent(0.5).cgColor, clearWhite.cgColor]
        gradient.locations = [0, 0.5, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        return gradient
    }
}
