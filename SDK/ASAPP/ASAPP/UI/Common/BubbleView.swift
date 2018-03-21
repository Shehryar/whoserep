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
    
    override var backgroundColor: UIColor? {
        didSet {
            guard let color = backgroundColor else { return }
            fillColor = color
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
            if oldValue != strokeColor {
                setNeedsDisplay()
            }
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
        backgroundColor = UIColor.clear
        contentMode = .redraw
    }
    
    // MARK: - Drawing
    
    func drawBubble(_ rect: CGRect) {
        
        let path = bubbleViewPath(for: rect)
    
        fillColor.setFill()
        path.fill()
        
        borderLayer?.removeFromSuperlayer()
        borderLayer = nil
        
        if let strokeColor = strokeColor {
            let border = CAShapeLayer()
            border.lineWidth = strokeLineWidth
            border.strokeColor = strokeColor.cgColor
            border.fillColor = nil
            border.frame = rect
            let strokeInset = strokeLineWidth / 2
            var transform = CGAffineTransform(scaleX: (rect.width - 2 * strokeInset) / rect.width, y: (rect.height - 2 * strokeInset) / rect.height).concatenating(CGAffineTransform(translationX: strokeInset, y: strokeInset))
            border.path = path.cgPath.copy(using: &transform)
            layer.addSublayer(border)
            borderLayer = border
        }
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
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
        
        let pi_2 = CGFloat.pi / 2.0
        let path = CGMutablePath()
        
        path.addArc(center: CGPoint(x: topLeftCornerCenter.x, y: topLeftCornerCenter.y),
                    radius: topLeftCornerRadius,
                    startAngle: 2 * pi_2,
                    endAngle: 3 * pi_2,
                    clockwise: false)
        
        path.addArc(center: CGPoint(x: topRightCornerCenter.x, y: topRightCornerCenter.y),
                    radius: topRightCornerRadius,
                    startAngle: 3 * pi_2,
                    endAngle: 4 * pi_2,
                    clockwise: false)
        
        path.addArc(center: CGPoint(x: bottomRightCornerCenter.x, y: bottomRightCornerCenter.y),
                    radius: bottomRightCornerRadius,
                    startAngle: 4 * pi_2,
                    endAngle: 5 * pi_2,
                    clockwise: false)
        
        path.addArc(center: CGPoint(x: bottomLeftCornerCenter.x, y: bottomLeftCornerCenter.y),
                    radius: bottomLeftCornerRadius,
                    startAngle: 5 * pi_2,
                    endAngle: 6 * pi_2,
                    clockwise: false)
        
        path.closeSubpath()
        
        return UIBezierPath(cgPath: path)
    }
}
