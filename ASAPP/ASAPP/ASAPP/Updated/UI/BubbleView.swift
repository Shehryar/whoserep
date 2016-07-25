//
//  BubbleView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class BubbleView: UIView {

    enum BubbleCorner {
        case None
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight
    }
    
    public var cornerRadius: CGFloat = 16.0 {
        didSet {
            if oldValue != cornerRadius {
                setNeedsDisplay()
            }
        }
    }
    
    /// The corner that does not use a corner radius
    public var hardCorner: BubbleCorner = .None {
        didSet {
            if oldValue != hardCorner {
                setNeedsDisplay()
            }
        }
    }
    
    public var fillColor = Colors.lightGrayColor() {
        didSet {
            if oldValue != fillColor {
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
        backgroundColor = UIColor.clearColor()
        contentMode = .Redraw
    }
    
    // MARK:- Drawing
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let cornerRadius = min(self.cornerRadius, CGRectGetHeight(rect) / 2.0)
        let cornerRadii = CGSize(width: cornerRadius, height: cornerRadius)
        var roundedCorners: UIRectCorner
        
        switch hardCorner {
        case .None:
            roundedCorners = .AllCorners
            break
            
        case .TopLeft:
            roundedCorners = [.TopRight, .BottomLeft, .BottomRight]
            break
            
        case .TopRight:
            roundedCorners = [.TopLeft, .BottomLeft, .BottomRight]
            break
            
        case .BottomLeft:
            roundedCorners = [.TopLeft, .TopRight, .BottomRight]
            break
            
        case .BottomRight:
            roundedCorners = [.TopLeft, .TopRight, .BottomLeft]
            break
        }
        
        fillColor.setFill()
        
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: roundedCorners,
                                cornerRadii: cornerRadii)
        path.fill()
    }
}
