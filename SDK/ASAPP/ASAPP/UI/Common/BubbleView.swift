//
//  BubbleView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class BubbleView: UIView, Bubble {
    var borderLayer: CAShapeLayer?
    
    var roundedCorners: UIRectCorner = .allCorners {
        didSet {
            if oldValue != roundedCorners {
                setNeedsDisplay()
            }
        }
    }
    
    var cornerRadius: CGFloat = 20 {
        didSet {
            if oldValue != cornerRadius {
                setNeedsDisplay()
            }
        }
    }
    
    var fillColor = UIColor(red: 0.937, green: 0.945, blue: 0.949, alpha: 1) {
        didSet {
            if oldValue != fillColor {
                setNeedsDisplay()
            }
        }
    }
    
    var strokeColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var strokeLineWidth: CGFloat = 0.5 {
        didSet {
            if oldValue != strokeLineWidth {
                setNeedsDisplay()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func draw(_ rect: CGRect) {
        drawBubble(rect)
    }
    
    func prepareForReuse() {}
}

protocol Bubble: class {
    var roundedCorners: UIRectCorner { get set }
    var cornerRadius: CGFloat { get set }
    var fillColor: UIColor { get set }
    var strokeColor: UIColor? { get set }
    var strokeLineWidth: CGFloat { get set }
    var borderLayer: CAShapeLayer? { get set }
}

extension Bubble where Self: UIView {
    
    // MARK: - Init
    
    func commonInit() {
        clipsToBounds = false
        backgroundColor = .clear
        contentMode = .redraw
        isOpaque = false
    }
    
    // MARK: - Drawing
    
    func drawBubble(_ rect: CGRect) {
        let fullPath = bubbleViewPath(for: rect)
        fillColor.setFill()
        
        borderLayer?.removeFromSuperlayer()
        borderLayer = nil
        
        if let strokeColor = strokeColor {
            let border = CAShapeLayer()
            border.fillColor = strokeColor.cgColor
            border.frame = rect
            let strokeInset = strokeLineWidth
            let transform = CGAffineTransform(scaleX: (rect.width - 2 * strokeInset) / rect.width, y: (rect.height - 2 * strokeInset) / rect.height).concatenating(CGAffineTransform(translationX: strokeInset, y: strokeInset))
            let innerPath = UIBezierPath(cgPath: fullPath.cgPath)
            innerPath.apply(transform)
            let borderPath = UIBezierPath(cgPath: fullPath.cgPath)
            borderPath.append(innerPath.reversing())
            border.path = borderPath.cgPath
            border.zPosition = .greatestFiniteMagnitude
            layer.addSublayer(border)
            borderLayer = border
            innerPath.fill()
        } else {
            fullPath.fill()
        }
        
        let mask = CAShapeLayer()
        mask.path = fullPath.cgPath
        layer.mask = mask
    }
    
    func bubbleViewPath(for rect: CGRect) -> UIBezierPath {
        let maxCornerRadius = rect.height / 2.0
        func getCornerRadius(_ corner: UIRectCorner) -> CGFloat {
            var cornerRadiusForCorner: CGFloat = 3.0
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
        
        let halfPi = CGFloat.pi / 2
        let path = CGMutablePath()
        
        path.addArc(center: CGPoint(x: topLeftCornerCenter.x, y: topLeftCornerCenter.y),
                    radius: topLeftCornerRadius,
                    startAngle: 2 * halfPi,
                    endAngle: 3 * halfPi,
                    clockwise: false)
        
        path.addArc(center: CGPoint(x: topRightCornerCenter.x, y: topRightCornerCenter.y),
                    radius: topRightCornerRadius,
                    startAngle: 3 * halfPi,
                    endAngle: 4 * halfPi,
                    clockwise: false)
        
        path.addArc(center: CGPoint(x: bottomRightCornerCenter.x, y: bottomRightCornerCenter.y),
                    radius: bottomRightCornerRadius,
                    startAngle: 4 * halfPi,
                    endAngle: 5 * halfPi,
                    clockwise: false)
        
        path.addArc(center: CGPoint(x: bottomLeftCornerCenter.x, y: bottomLeftCornerCenter.y),
                    radius: bottomLeftCornerRadius,
                    startAngle: 5 * halfPi,
                    endAngle: 6 * halfPi,
                    clockwise: false)
        
        path.closeSubpath()
        
        return UIBezierPath(cgPath: path)
    }
}
