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
        
        font = ASAPP.styles.textStyles.body.font.changingOnlySize(14)
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        blurredBackground.frame = contentView.bounds
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
    
    func showSpinner() {
        isUserInteractionEnabled = false
        
        activityIndicator?.removeFromSuperview()
        activityIndicator = UIActivityIndicatorView(frame: frame)
        if let spinner = activityIndicator {
            spinner.backgroundColor = .clear
            spinner.activityIndicatorViewStyle = .gray
            spinner.sizeToFit()
            spinner.frame = CGRect(x: imageView.frame.minX, y: label.center.y - (spinner.frame.height / 2), width: spinner.frame.size.width, height: spinner.frame.size.height)
            insertSubview(spinner, belowSubview: label)
            spinner.startAnimating()
            spinner.alpha = 0
        }
        
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.activityIndicator?.alpha = 1
            self?.label.alpha = 0
            self?.imageView.alpha = 0
        }
    }
    
    func hideSpinner() {
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            self?.activityIndicator?.alpha = 0
            self?.label.alpha = 1
            self?.imageView.alpha = 1
        }, completion: { [weak self] _ in
            self?.activityIndicator?.removeFromSuperview()
            self?.activityIndicator = nil
            self?.isUserInteractionEnabled = true
        })
    }
}
