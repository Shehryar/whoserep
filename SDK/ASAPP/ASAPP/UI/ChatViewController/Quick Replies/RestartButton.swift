//
//  RestartButton.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 3/12/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class RestartButton: Button {
    let defaultHeight: CGFloat = 54
    let animationDuration: TimeInterval = 0.3
    
    override var frame: CGRect {
        didSet {
            activityIndicator?.frame = getSpinnerFrame()
        }
    }
    
    private let blurredBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private var activityIndicator: UIActivityIndicatorView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        contentAlignment = .left
        contentView.backgroundColor = .clear
        
        blurredBackground.isHidden = true
        contentView.insertSubview(blurredBackground, at: 0)
        blurredBackground.frame = contentView.bounds
        
        imageSize = CGSize(width: 18, height: 16.5)
        image = Images.getImage(.iconNewQuestion)
        
        title = ASAPP.strings.quickRepliesRestartButton
        accessibilityLabel = title
        
        setForegroundColor(ASAPP.styles.colors.textButtonPrimary.textNormal, forState: .normal)
        setForegroundColor(ASAPP.styles.colors.textButtonPrimary.textHighlighted, forState: .highlighted)
        
        imageTitleMargin = 8
        
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowColor = ASAPP.styles.colors.textButtonPrimary.textNormal.withAlphaComponent(0.05).cgColor
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 3
        
        imageView.layer.shadowOffset = label.layer.shadowOffset
        imageView.layer.shadowColor = label.layer.shadowColor
        imageView.layer.shadowOpacity = label.layer.shadowOpacity
        imageView.layer.shadowRadius = label.layer.shadowRadius
        
        updateDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        blurredBackground.frame = contentView.bounds
    }
    
    func updateDisplay() {
        font = ASAPP.styles.textStyles.body.font.changingOnlySize(14)
    }
    
    func hideBlur() {
        blurredBackground.isHidden = true
        blurredBackground.removeFromSuperview()
        contentView.backgroundColor = .clear
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    func replaceBlur() {
        if blurredBackground.superview == nil {
            contentView.backgroundColor = .white
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    func showBlur() {
        if blurredBackground.superview == nil {
            contentView.insertSubview(blurredBackground, at: 0)
            blurredBackground.frame = contentView.bounds
        }
        blurredBackground.isHidden = false
        contentView.backgroundColor = .clear
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    private func getSpinnerFrame() -> CGRect {
        let currentFrame = activityIndicator?.frame ?? .zero
        return CGRect(x: contentInset.left, y: (bounds.height / 2) - (currentFrame.height / 2), width: currentFrame.size.width, height: currentFrame.size.height)
    }
    
    func showSpinner(animated: Bool) {
        isUserInteractionEnabled = false
        
        activityIndicator?.removeFromSuperview()
        activityIndicator = UIActivityIndicatorView(frame: frame)
        if let spinner = activityIndicator {
            spinner.backgroundColor = .clear
            spinner.style = .gray
            spinner.sizeToFit()
            spinner.frame = getSpinnerFrame()
            insertSubview(spinner, belowSubview: label)
            spinner.startAnimating()
            spinner.alpha = 0
        }
        
        func animationHandler() {
            activityIndicator?.alpha = 1
            label.alpha = 0
            imageView.alpha = 0
        }
        
        UIView.animateIfNeeded(animated, withDuration: animationDuration, animations: animationHandler)
    }
    
    func hideSpinner(animated: Bool) {
        func animationHandler() {
            activityIndicator?.alpha = 0
            label.alpha = 1
            imageView.alpha = 1
        }
        
        func completionHandler(_ done: Bool) {
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
            isUserInteractionEnabled = true
        }
        
        UIView.animateIfNeeded(animated, withDuration: animationDuration, animations: animationHandler, completion: completionHandler)
    }
}
