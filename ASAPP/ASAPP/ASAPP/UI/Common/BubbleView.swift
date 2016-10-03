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
    
    var roundedCorners: UIRectCorner = .allCorners {
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
    
    fileprivate let maskLayer = CAShapeLayer()
    
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
        backgroundColor = UIColor.clear
        contentMode = .redraw
        
        if UIScreen.main.scale > 1 {
            strokeLineWidth = 0.5
        }
    }
    
    // MARK:- Drawing
    
    override func draw(_ rect: CGRect) {
        
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
            maskLayer.path = clippingPath.cgPath
            layer.mask = maskLayer
        } else {
            layer.mask = nil
        }
    }
    
    func bubbleViewPath(forRect originalRect: CGRect, insetForStroke: Bool) -> UIBezierPath {
        var rect = originalRect
        let strokeInset = strokeLineWidth / 2.0
        if insetForStroke {
            rect = originalRect.insetBy(dx: strokeInset, dy: strokeInset)
        }
        
        let maxCornerRadius = rect.height / 2.0
        func getCornerRadius(_ corner: UIRectCorner) -> CGFloat {
            var cornerRadiusForCorner = smallCornerRadius
            if roundedCorners.contains(corner) {
                cornerRadiusForCorner = cornerRadius
            }
            return min(cornerRadiusForCorner, maxCornerRadius)
        }
        
        func move(_ point: CGPoint, x: CGFloat, y: CGFloat) -> CGPoint {
            var movedPoint = point
            movedPoint.x += x
            movedPoint.y += y
            return movedPoint
        }
        
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topLeftCornerRadius = getCornerRadius(.topLeft)
        let topLeftCornerCenter = move(topLeft, x: topLeftCornerRadius, y: topLeftCornerRadius)
        
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let topRightCornerRadius = getCornerRadius(.topRight)
        let topRightCornerCenter = move(topRight, x: -topRightCornerRadius, y: topRightCornerRadius)
        
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomRightCornerRadius = getCornerRadius(.bottomRight)
        let bottomRightCornerCenter = move(bottomRight, x: -bottomRightCornerRadius, y: -bottomRightCornerRadius)
        
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomLeftCornerRadius = getCornerRadius(.bottomLeft)
        let bottomLeftCornerCenter = move(bottomLeft, x: bottomLeftCornerRadius, y: -bottomLeftCornerRadius)
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: topLeftCornerCenter.x, y: topLeftCornerCenter.y), radius: topLeftCornerRadius, startAngle: CGFloat(2 * M_PI_2), endAngle: CGFloat(3 * M_PI_2), clockwise: false)
        path.addArc(center: CGPoint(x: topRightCornerCenter.x, y: topRightCornerCenter.y), radius: topRightCornerRadius, startAngle: CGFloat(3 * M_PI_2), endAngle: CGFloat(4 * M_PI_2), clockwise: false)
        path.addArc(center: CGPoint(x: bottomRightCornerCenter.x, y: bottomRightCornerCenter.y), radius: bottomRightCornerRadius, startAngle: CGFloat(4 * M_PI_2), endAngle: CGFloat(5 * M_PI_2), clockwise: false)
        path.addArc(center: CGPoint(x: bottomLeftCornerCenter.x, y: bottomLeftCornerCenter.y), radius: bottomLeftCornerRadius, startAngle: CGFloat(5 * M_PI_2), endAngle: CGFloat(6 * M_PI_2), clockwise: false)
        path.closeSubpath()
        
        return UIBezierPath(cgPath: path)
    }
}
