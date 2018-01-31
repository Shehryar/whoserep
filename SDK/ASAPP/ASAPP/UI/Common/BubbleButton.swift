//
//  BubbleButton.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

class BubbleButton: Button {
    var bubble: BubbleView {
        return contentView as! BubbleView
    }
    
    override func commonInit() {
        contentView = BubbleView(frame: frame)
        
        bubble.roundedCorners = [.bottomLeft, .topLeft, .topRight]
        bubble.strokeLineWidth = UIScreen.main.scale > 1 ? 0.5 : 1
        
        super.commonInit()
    }
    
    override func updateBackgroundColor() {
        if let bgColor = backgroundColorForState(currentState) {
            bubble.fillColor = bgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bubble.cornerRadius = bubble.frame.height / 2
    }
}
