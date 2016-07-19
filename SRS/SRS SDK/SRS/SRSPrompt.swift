//
//  SRSPrompt.swift
//  XfinityMyAccount
//
//  Created by Vicky Sehrawat on 3/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSPrompt: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addPromtText()
        self.addExit()
        self.backgroundColor = UIColor.clearColor()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var prompt: UILabel!
    func addPromtText() {
        prompt = UILabel()
        prompt.textAlignment = NSTextAlignment.Center
        prompt.textColor = UIColor.whiteColor()
        prompt.font = UIFont(name: "HelveticaNeue", size: 14)
        self.addSubview(prompt)
        
        prompt.translatesAutoresizingMaskIntoConstraints = false
        let xPosition = NSLayoutConstraint(item: prompt, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let yPosition = NSLayoutConstraint(item: prompt, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        let widthContraint = NSLayoutConstraint(item: prompt, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let heightContraint = NSLayoutConstraint(item: prompt, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 14)
        
        self.addConstraint(yPosition)
        self.addConstraint(widthContraint)
        self.addConstraint(heightContraint)
        self.addConstraint(xPosition)
    }
    
    var exitButton: UIButton!
    func addExit() {
        let exitColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        exitButton = UIButton()
        exitButton.setTitle("EXIT", forState: .Normal)
        exitButton.setTitleColor(exitColor, forState: .Normal)
        exitButton.titleLabel?.font = UIFont(name: "XFINITYSans-BoldCond", size: 13)
        self.addSubview(exitButton)
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        let centerY = NSLayoutConstraint(item: exitButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: exitButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: exitButton, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: exitButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 60)
        
        self.addConstraint(centerY)
        self.addConstraint(right)
        self.addConstraint(height)
        self.addConstraint(width)
        
        exitButton.addTarget(self, action: "exitAction:", forControlEvents: .TouchUpInside)
    }
    
    func exitAction(sender: UIButton) {
        if SRS.instance == nil {
            return
        }
        
        SRS.instance.colapse()
    }
    
    func addRipple() {
        let rippleView = UIView(frame: CGRect(x: (self.frame.size.width/2), y: 40, width: 50, height: 50))
        rippleView.backgroundColor = UIColor.clearColor()
        let rippleLayer = CAShapeLayer()
        let ripple = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: 8, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        rippleLayer.path = ripple.CGPath
        rippleLayer.fillColor = UIColor.clearColor().CGColor
        rippleLayer.lineWidth = 1
        rippleLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9).CGColor
        rippleView.layer.addSublayer(rippleLayer)
        
        self.addSubview(rippleView)
        
        let expandAnim = CABasicAnimation(keyPath: "transform.scale")
        expandAnim.fromValue = 1
        expandAnim.toValue = 5
        expandAnim.duration = 1
        expandAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        expandAnim.removedOnCompletion = false
        expandAnim.fillMode = kCAFillModeForwards
        rippleLayer.addAnimation(expandAnim, forKey: "expandRipple")
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            rippleView.alpha = 0.0
            }) { (didFinish) -> Void in
                rippleView.removeFromSuperview()
        }
    }
    
    func addRippleForDuration(duration: NSTimeInterval) -> NSTimer {
        let rippleTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "addRippleTimer:", userInfo: nil, repeats: true)
        
        return rippleTimer
    }
    
    func addRippleTimer(sender: NSTimer) {
        self.addRipple()
    }

    func setPromptText(text: String) {
        prompt.text = text.uppercaseString
    }
}
