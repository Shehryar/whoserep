//
//  SRSMenuItemView.swift
//  XfinityMyAccount
//
//  Created by Vicky Sehrawat on 3/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSMenuItemView: UILabel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsetsMake(20, 20, 20, 20)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
}
