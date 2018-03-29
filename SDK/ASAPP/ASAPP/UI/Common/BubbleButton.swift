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
    
    var isEnabled: Bool = true {
        didSet {
            alpha = isEnabled ? 1 : 0.5
            setNeedsDisplay()
        }
    }
    
    override func commonInit() {
        contentView = BubbleView(frame: frame)
        
        bubble.roundedCorners = [.bottomLeft, .topLeft, .topRight]
        bubble.strokeLineWidth = 1
        
        super.commonInit()
    }
    
    override func updateBackgroundColor() {
        if let bgColor = backgroundColorForState(currentState) {
            bubble.fillColor = bgColor
        }
    }
}
