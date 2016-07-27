//
//  BubbleView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class BubbleView: UIView {

    var cornerRadius: CGFloat = 16.0 {
        didSet {
            if oldValue != cornerRadius {
                setNeedsDisplay()
            }
        }
    }
    
    var roundedCorners: UIRectCorner = .AllCorners {
        didSet {
            if oldValue != roundedCorners {
                setNeedsDisplay()
            }
        }
    }
    
    var fillColor = Colors.lighterGrayColor() {
        didSet {
            if oldValue != fillColor {
                setNeedsDisplay()
            }
        }
    }
    
    var strokeColor: UIColor? {
        didSet {
            if oldValue != strokeColor {
                setNeedsDisplay()
            }
        }
    }
    
    var strokeLineWidth: CGFloat = 1 {
        didSet {
            if oldValue != strokeLineWidth {
                setNeedsDisplay()
            }
        }
    }
    
    // MARK:- Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        clipsToBounds = false
        backgroundColor = UIColor.clearColor()
        contentMode = .Redraw
    }
    
    // MARK:- Drawing
    
    override func drawRect(rect: CGRect) {
        let path = bubbleViewPath(forRect: rect)
        fillColor.setFill()
        path.fill()
        if let strokeColor = strokeColor {
            strokeColor.setStroke()
            path.lineWidth = strokeLineWidth
            path.stroke()
        }
    }
    
    func bubbleViewPath(forRect rect: CGRect) -> UIBezierPath {
        let cornerRadius = min(self.cornerRadius, CGRectGetHeight(rect) / 2.0)
        let cornerRadii = CGSize(width: cornerRadius, height: cornerRadius)
    
        var sizedRect = rect
        if strokeColor != nil {
            sizedRect = CGRectInset(rect, strokeLineWidth, strokeLineWidth)
        }
        
        return UIBezierPath(roundedRect: sizedRect,
                            byRoundingCorners: roundedCorners,
                            cornerRadii: cornerRadii)
    }
}
