//
//  SRSTutorial.swift
//  XfinityMyAccount
//
//  Created by Vicky Sehrawat on 3/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSTutorial: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.addIntroLabel()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addIntroLabel() {
        let label = UILabel()
        label.text = "TAP HERE ANYTIME TO MINIMIZE"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(14)
        
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let xPos = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 80)
        let yPos = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        self.addConstraint(xPos)
        self.addConstraint(height)
        self.addConstraint(yPos)
        
        SRS.prompt.setPromptText("")
        let tapGesture = UITapGestureRecognizer(target: self, action: "hideTutorial:")
        self.addGestureRecognizer(tapGesture)
    }
    
    func hideTutorial(sender: UITapGestureRecognizer) {
        print("hide tutorial")
        SRS.prompt.setPromptText("HOW CAN WE HELP?")
        self.removeFromSuperview()
    }

}
