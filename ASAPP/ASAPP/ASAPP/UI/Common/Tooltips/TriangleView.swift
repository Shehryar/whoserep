//
//  TriangleView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 11/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class TriangleView: UIView {

    enum Direction {
        // case left
        case up
        // case right
        // case down
    }
    
    var fillColor: UIColor = UIColor.black.withAlphaComponent(0.6) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var direction: Direction = .up {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    
    // MARK:- Drawing
    
    override func draw(_ rect: CGRect) {
        let path = trianglePath(forRect: rect)
        fillColor.setFill()
        path.fill()
    }

    func trianglePath(forRect rect: CGRect) -> UIBezierPath {
        let path = CGMutablePath()
        
        switch direction {
        case .up:
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY)) // bottom-left
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY)) // top-middle
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // bottom-right
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // bottom-left
            break
        }
        
        return UIBezierPath(cgPath: path)
    }
}
