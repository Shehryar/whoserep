//
//  ASAPPBubbleView.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ASAPPBubbleView: UIView {

    var shouldShowBorder: Bool = false
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        UIColor(red: 202/255, green: 202/255, blue: 202/255, alpha: 1).setStroke()
        UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1).setFill()
        
        var roundedRect = rect
        roundedRect.size.width -= 4
        roundedRect.size.height -= 4
        roundedRect.origin.x += 2
        roundedRect.origin.y += 2
        
        let borderPath = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: [UIRectCorner.TopRight, UIRectCorner.TopLeft, UIRectCorner.BottomRight], cornerRadii: CGSizeMake(20, 20))
        let fillPath = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: [UIRectCorner.TopRight, UIRectCorner.TopLeft, UIRectCorner.BottomLeft], cornerRadii: CGSizeMake(20, 20))
        if shouldShowBorder {
            borderPath.stroke()
        } else {
            fillPath.fill()
        }
    }

}