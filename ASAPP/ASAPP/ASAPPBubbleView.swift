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
    var isCustomerEvent: Bool = false
    var state: ASAPPState!
    
    convenience init(state: ASAPPState) {
        self.init()
        self.state = state
    }
    
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
        var fillPath = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: [UIRectCorner.TopRight, UIRectCorner.TopLeft, UIRectCorner.BottomLeft], cornerRadii: CGSizeMake(20, 20))
        if !state.isCustomer() && isCustomerEvent {
            fillPath = borderPath
            UIColor(red: 121/255, green: 127/255, blue: 144/255, alpha: 1).setFill()
        }
        
        if shouldShowBorder {
            borderPath.stroke()
        } else {
            fillPath.fill()
        }
    }

}
