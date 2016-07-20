//
//  SRSCircle.swift
//  XfinityMyAccount
//
//  Created by Vicky Sehrawat on 3/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSCircle: UIView {
    var icon: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.addSRSMini(frame)
        self.addIcon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var srsLayer: CAShapeLayer!
    func addSRSMini(frame: CGRect) {
        let circle = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2.0, y: frame.size.height/2.0), radius: frame.size.width/2.0, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        srsLayer = CAShapeLayer()
        srsLayer.path = circle.CGPath
        srsLayer.fillColor = UIColor(red: 26/255, green: 39/255, blue: 71/255, alpha: 0.9).CGColor
        self.layer.addSublayer(srsLayer)
        NSLog("ADDED SRS MINI")
    }
    
    func addIcon() {
        icon = UIImageView()
        
        let framework = NSBundle(forClass: SRSCircle.self)
        let iconImage = UIImage(named: "icon", inBundle: framework, compatibleWithTraitCollection: nil)
        icon.image = iconImage
        self.addSubview(icon)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        let xPos = NSLayoutConstraint(item: icon, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let yPos = NSLayoutConstraint(item: icon, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: icon, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 60)
        let height = NSLayoutConstraint(item: icon, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 60)
        
        self.addConstraint(xPos)
        self.addConstraint(yPos)
        self.addConstraint(width)
        self.addConstraint(height)
    }
    
    func expandSRS(completion: () -> Void) {
        UIView.animateWithDuration(0.3, animations: {
            self.icon.alpha = 0.0
            }) { (status) in
                print("MY FRAME", self.frame.origin.x, self.frame.origin.y)
                let expandAnim = CABasicAnimation(keyPath: "transform.scale")
                //expandAnim.fromValue = 1
                expandAnim.toValue = 65
                expandAnim.duration = 0.5
                expandAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                expandAnim.removedOnCompletion = false
                expandAnim.fillMode = kCAFillModeForwards
                self.layer.addAnimation(expandAnim, forKey: "expandSRS")
                completion()
        }
    }
    
    func colapseSRS() {
        print("Colapse MY FRAME", self.frame.origin.x, self.frame.origin.y)
        let expandAnim = CABasicAnimation(keyPath: "transform.scale")
        expandAnim.fromValue = 65
        expandAnim.toValue = 1
        expandAnim.duration = 0.5
        expandAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        expandAnim.removedOnCompletion = false
        expandAnim.fillMode = kCAFillModeForwards
        expandAnim.delegate = self
        self.layer.addAnimation(expandAnim, forKey: "colapseSRS")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        UIView.animateWithDuration(0.2) {
            self.icon.alpha = 1.0
        }
    }
}
