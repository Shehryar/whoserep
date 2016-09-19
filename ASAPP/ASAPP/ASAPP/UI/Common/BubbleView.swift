//
//  BubbleView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class BubbleView: UIView {

    var cornerRadius: CGFloat = 14.0 {
        didSet {
            if oldValue != cornerRadius {
                setNeedsDisplay()
            }
        }
    }
    
    var smallCornerRadius: CGFloat = 3.0 {
        didSet {
            if oldValue != smallCornerRadius {
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
    
    var clipsToBubblePath = false {
        didSet {
            if oldValue != clipsToBubblePath {
                setNeedsDisplay()
            }
        }
    }
    
    private let maskLayer = CAShapeLayer()
    
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
        
        let path = bubbleViewPath(forRect: rect, insetForStroke: (strokeColor != nil))
    
        fillColor.setFill()
        path.fill()
        if let strokeColor = strokeColor {
            strokeColor.setStroke()
            path.lineWidth = strokeLineWidth
            path.stroke()
        }
        
        if clipsToBubblePath {
            let clippingPath = bubbleViewPath(forRect: rect, insetForStroke: false)
            maskLayer.path = clippingPath.CGPath
            layer.mask = maskLayer
        } else {
            layer.mask = nil
        }
    }
    
    func bubbleViewPath(forRect originalRect: CGRect, insetForStroke: Bool) -> UIBezierPath {
        var rect = originalRect
        let strokeInset = strokeLineWidth / 2.0
        if insetForStroke {
            rect = CGRectInset(originalRect, strokeInset, strokeInset)
        }
        
        let maxCornerRadius = CGRectGetHeight(rect) / 2.0
        func getCornerRadius(corner: UIRectCorner) -> CGFloat {
            var cornerRadiusForCorner = smallCornerRadius
            if roundedCorners.contains(corner) {
                cornerRadiusForCorner = cornerRadius
            }
            return min(cornerRadiusForCorner, maxCornerRadius)
        }
        
        func move(point: CGPoint, x: CGFloat, y: CGFloat) -> CGPoint {
            var movedPoint = point
            movedPoint.x += x
            movedPoint.y += y
            return movedPoint
        }
        
        let topLeft = CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMinY(rect))
        let topLeftCornerRadius = getCornerRadius(.TopLeft)
        let topLeftCornerCenter = move(topLeft, x: topLeftCornerRadius, y: topLeftCornerRadius)
        
        let topRight = CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMinY(rect))
        let topRightCornerRadius = getCornerRadius(.TopRight)
        let topRightCornerCenter = move(topRight, x: -topRightCornerRadius, y: topRightCornerRadius)
        
        let bottomRight = CGPoint(x: CGRectGetMaxX(rect), y: CGRectGetMaxY(rect))
        let bottomRightCornerRadius = getCornerRadius(.BottomRight)
        let bottomRightCornerCenter = move(bottomRight, x: -bottomRightCornerRadius, y: -bottomRightCornerRadius)
        
        let bottomLeft = CGPoint(x: CGRectGetMinX(rect), y: CGRectGetMaxY(rect))
        let bottomLeftCornerRadius = getCornerRadius(.BottomLeft)
        let bottomLeftCornerCenter = move(bottomLeft, x: bottomLeftCornerRadius, y: -bottomLeftCornerRadius)
        
        let path = CGPathCreateMutable()
    
        CGPathAddArc(path, nil, topLeftCornerCenter.x, topLeftCornerCenter.y, topLeftCornerRadius, CGFloat(2 * M_PI_2), CGFloat(3 * M_PI_2), false)
        CGPathAddArc(path, nil, topRightCornerCenter.x, topRightCornerCenter.y, topRightCornerRadius, CGFloat(3 * M_PI_2), CGFloat(4 * M_PI_2), false)
        CGPathAddArc(path, nil, bottomRightCornerCenter.x, bottomRightCornerCenter.y, bottomRightCornerRadius, CGFloat(4 * M_PI_2), CGFloat(5 * M_PI_2), false)
        CGPathAddArc(path, nil, bottomLeftCornerCenter.x, bottomLeftCornerCenter.y, bottomLeftCornerRadius, CGFloat(5 * M_PI_2), CGFloat(6 * M_PI_2), false)
        CGPathCloseSubpath(path)
        
        return UIBezierPath(CGPath: path)
    }
}
