//
//  SRSButton.swift
//  XfinityMyAccount
//
//  Created by Vicky Sehrawat on 3/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSButton: UIButton {

    var label: String!
    var key: [String: AnyObject]!
    var colorScheme: String!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var labelRect = self.titleLabel?.frame
        var imageRect = self.imageView?.frame
        
        imageRect?.origin.y = (self.frame.size.height - ((labelRect?.size.height)! + (imageRect?.size.height)! + 10)) / 2
        self.imageView?.frame = imageRect!
        self.imageView?.center.x = (self.titleLabel?.center.x)!
        
        labelRect?.origin.x = 10
        labelRect?.size.width = self.frame.width - 20
        if self.imageView?.image != nil {
            labelRect?.origin.y = (imageRect?.size.height)! + (imageRect?.origin.y)! + 10
        }

        self.titleLabel?.frame = labelRect!
        
//        self.imageView?.backgroundColor = UIColor.greenColor()
//        self.titleLabel?.backgroundColor = UIColor.blueColor()
    }

}
