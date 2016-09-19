//
//  TroubleshooterView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class TroubleshooterView: UIView {

    var isShowing: Bool {
        return self.alpha > 0
    }
    
    private let containerView = UIView()
    
    private let label = UILabel()
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
    
    private var animating = false
    
    // MARK: Initialization
    
    func commonInit() {
        alpha = 0.0
        userInteractionEnabled = false
        
        backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)
        
        containerView.backgroundColor = Colors.steelDarkColor()
        containerView.layer.cornerRadius = 8.0
        containerView.layer.shadowColor = UIColor.blackColor().CGColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        addSubview(containerView)
        
        label.numberOfLines = 0
        label.lineBreakMode = .ByTruncatingTail
        label.textColor = UIColor.whiteColor()
        label.font = Fonts.latoBoldFont(withSize: 18)
        label.text = ASAPPLocalizedString("Restarting your device. This may take several minutes...")
        label.textAlignment = .Center
        containerView.addSubview(label)
        
        spinner.hidesWhenStopped = true
        containerView.addSubview(spinner)
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
        
        if !animating {
            updateFrames()
        }
    }
    
    func updateFrames() {
        
        let containerWidth = min(280, floor(0.7 * CGRectGetWidth(bounds)))
        let containerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let labelWidth = containerWidth - containerInset.left - containerInset.right
        let labelHeight = ceil(label.sizeThatFits(CGSize(width: labelWidth, height: 0)).height)
        label.frame = CGRect(x: containerInset.left, y: containerInset.top, width: labelWidth, height: labelHeight)
        
        spinner.sizeToFit()
        let spinnerCtrY = ceil(CGRectGetMaxY(label.frame) + CGRectGetHeight(spinner.bounds) / 2.0 + containerInset.bottom)
        spinner.center = CGPoint(x: label.center.x, y: spinnerCtrY)
        
        let containerHeight = CGRectGetMaxY(spinner.frame) + containerInset.bottom
        let containerTop = floor((CGRectGetHeight(bounds) - containerHeight) / 2.0)
        let containerLeft = floor((CGRectGetWidth(bounds) - containerWidth) / 2.0)
        containerView.frame = CGRect(x: containerLeft, y: containerTop, width: containerWidth, height: containerHeight)
    }
    
    // MARK: Showing / Hiding
    
    func showTroubleshooter(completion: (() -> Void)? = nil) {
        if isShowing {
            return
        }
        
        updateFrames()
        containerView.alpha = 0.0
        containerView.transform = CGAffineTransformMakeScale(0.01, 0.01)
        spinner.startAnimating()
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.alpha = 1.0
            self.userInteractionEnabled = true
            
            }) { (completed) in
                
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: { 
                    
                    self.containerView.alpha = 1.0
                    self.containerView.transform = CGAffineTransformIdentity
                    
                    }, completion: { (completed2) in
                        completion?()
                })
        }
    }
    
    func hideTroubleshooter(completion: (() -> Void)? = nil) {
        UIView.animateWithDuration(0.3, animations: { 
            self.alpha = 0.0
            self.userInteractionEnabled = false
            }) { (completed) in
                self.spinner.stopAnimating()
                
                completion?()
        }
    }
}
