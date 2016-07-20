//
//  ASAPPBubbleView.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ASAPPBubbleView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var topLeftCorner: UIView!
    var topRightCorner: UIView!
    var bottomLeftCorner: UIView!
    var bottomRightCorner: UIView!
    var centerView: UIView!
    var leftCenterView: UIView!
    var rightCenterView: UIView!
    
    let CORNER_RADIUS: CGFloat = 18
    
    var isMyEvent: Bool = false
    
    let strokeColor: UIColor = UIColor(red: 202/255, green: 202/255, blue: 202/255, alpha: 1)
    
    func render(reuseIdentifer: String) {
        var bubbleColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        var isStroke = false
        isMyEvent = false
        
        if reuseIdentifer == ASAPPChatTableView.CELL_IDENT_MSG_SEND {
            isMyEvent = true
        } else if reuseIdentifer == ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE {
            bubbleColor = UIColor.whiteColor()
            isStroke = true
        } else if reuseIdentifer == ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE_CUSTOMER {
            bubbleColor = UIColor.blueColor()
        }
        
        createCornersIfNeeded(bubbleColor, isStroke: isStroke)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }
    
    func createCornersIfNeeded(bgColor: UIColor, isStroke: Bool) {
        var cornerRaius = CORNER_RADIUS
        if isStroke {
            cornerRaius -= 0.5
        }
        
        if topLeftCorner == nil {
            topLeftCorner = viewWithPathAndColor(.TopLeft, cornerRadius: cornerRaius, backgroundColor: bgColor, isStroke: isStroke)
            self.addSubview(topLeftCorner)
        }
        if topRightCorner == nil {
            topRightCorner = viewWithPathAndColor(.TopRight, cornerRadius: cornerRaius, backgroundColor: bgColor, isStroke: isStroke)
            self.addSubview(topRightCorner)
        }
        if bottomLeftCorner == nil && isMyEvent {
            bottomLeftCorner = viewWithPathAndColor(.BottomLeft, cornerRadius: cornerRaius, backgroundColor: bgColor, isStroke: isStroke)
            self.addSubview(bottomLeftCorner)
        }
        if bottomRightCorner == nil && !isMyEvent {
            bottomRightCorner = viewWithPathAndColor(.BottomRight, cornerRadius: cornerRaius, backgroundColor: bgColor, isStroke: isStroke)
            self.addSubview(bottomRightCorner)
        }
        
        if centerView == nil {
            centerView = fillerView([.Top, .Bottom], edgeColor: strokeColor, isStroke: isStroke)
            centerView.backgroundColor = bgColor
            self.addSubview(centerView)
        }
        
        if leftCenterView == nil {
            var cornersForSideFiller: [UIRectEdge] = [.Left]
            if !isMyEvent {
                cornersForSideFiller.append(.Bottom)
            }
            leftCenterView = fillerView(cornersForSideFiller, edgeColor: strokeColor, isStroke: isStroke)
            leftCenterView.backgroundColor = bgColor
            self.addSubview(leftCenterView)
        }
        
        if rightCenterView == nil {
            var cornersForSideFiller: [UIRectEdge] = [.Right]
            if isMyEvent {
                cornersForSideFiller.append(.Bottom)
            }
            rightCenterView = fillerView(cornersForSideFiller, edgeColor: strokeColor, isStroke: isStroke)
            rightCenterView.backgroundColor = bgColor
            self.addSubview(rightCenterView)
        }
    }
    
    func fillerView(edges: [UIRectEdge], edgeColor: UIColor, isStroke: Bool) -> UIView {
        let view = UIView()
        if !isStroke {
            return view
        }
        
        for edge in edges {
            let edgeView = UIView()
            edgeView.backgroundColor = edgeColor
            view.addSubview(edgeView)
            
            edgeView.snp_makeConstraints(closure: { (make) in
                if edge == .Top || edge == .Bottom {
                    make.height.equalTo(1)
                } else {
                    make.width.equalTo(1)
                }
                
                if edge != .Right {
                    make.leading.equalTo(view.snp_leading)
                }
                if edge != .Left {
                    make.trailing.equalTo(view.snp_trailing)
                }
                if edge != .Top {
                    make.bottom.equalTo(view.snp_bottom)
                }
                if edge != .Bottom {
                    make.top.equalTo(view.snp_top)
                }
            })
        }
        
        return view
    }
    
    func viewWithPathAndColor(corner: UIRectCorner, cornerRadius: CGFloat, backgroundColor: UIColor, isStroke: Bool) -> UIView {
        let view = UIView()
        let path = pathWithRoundCorner(corner, cornerRadius: cornerRadius, isStroke: isStroke)
        
        var offsetX: CGFloat = 0.5
        var offsetY: CGFloat = 0.5
        if isStroke {
            if corner == .BottomLeft {
                offsetX = 0.5
                offsetY = 0
            } else if corner == .BottomRight {
                offsetX = 0
                offsetY = 0
            } else if corner == .TopRight {
                offsetX = 0
                offsetY = 0.5
            }
        }
        
        let borderLayer = CAShapeLayer()
        borderLayer.frame = CGRectMake(offsetX, offsetY, cornerRadius, cornerRadius)
        borderLayer.path = path
        borderLayer.fillColor = backgroundColor.CGColor
        if isStroke {
            borderLayer.strokeColor = strokeColor.CGColor
        }
        
        view.clipsToBounds = true
        view.layer.addSublayer(borderLayer)
        
        return view
    }
    
    func pathWithRoundCorner(corner: UIRectCorner, cornerRadius: CGFloat, isStroke: Bool) -> CGPath {
        var centerPoint = CGPointMake(0, 0)
        var startAngle = M_PI * 0
        var endAngle = M_PI * 1.5
        var startPoint = CGPointMake(cornerRadius, 0)
        
        if corner == .BottomLeft {
            centerPoint = CGPointMake(cornerRadius, 0)
            startAngle = M_PI * 1.5
            endAngle = M_PI
            startPoint = CGPointMake(cornerRadius, cornerRadius)
        } else if corner == .TopRight {
            centerPoint = CGPointMake(0, cornerRadius)
            startAngle = M_PI / 2
            endAngle = M_PI * 2
            startPoint = CGPointMake(0, 0)
        } else if corner == .TopLeft {
            centerPoint = CGPointMake(cornerRadius, cornerRadius)
            startAngle = M_PI
            endAngle = M_PI / 2
            startPoint = CGPointMake(0, cornerRadius)
        }
        
        var borderPath = UIBezierPath()
        if !isStroke {
            borderPath.moveToPoint(centerPoint)
            borderPath.addLineToPoint(startPoint)
        }
        borderPath.addArcWithCenter(centerPoint, radius: cornerRadius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
        if !isStroke {
            borderPath.addLineToPoint(centerPoint)
        }
        
        return borderPath.CGPath
    }
    
    override func updateConstraints() {
        // HACK
        if topLeftCorner == nil {
            super.updateConstraints()
            return
        }
        // END
        
        topLeftCorner.snp_updateConstraints { (make) in
            make.top.equalTo(self.snp_top)
            make.leading.equalTo(self.snp_leading)
            make.width.equalTo(CORNER_RADIUS)
            make.height.equalTo(CORNER_RADIUS)
        }

        topRightCorner.snp_updateConstraints { (make) in
            make.top.equalTo(self.snp_top)
            make.trailing.equalTo(self.snp_trailing)
            make.width.equalTo(CORNER_RADIUS)
            make.height.equalTo(CORNER_RADIUS).priorityMedium()
        }
        
        if isMyEvent {
            bottomLeftCorner.snp_updateConstraints(closure: { (make) in
                make.bottom.equalTo(self.snp_bottom)
                make.leading.equalTo(self.snp_leading)
                make.width.equalTo(CORNER_RADIUS)
                make.height.equalTo(CORNER_RADIUS)
            })
        } else {
            bottomRightCorner.snp_updateConstraints(closure: { (make) in
                make.bottom.equalTo(self.snp_bottom)
                make.trailing.equalTo(self.snp_trailing)
                make.width.equalTo(CORNER_RADIUS)
                make.height.equalTo(CORNER_RADIUS)
            })
        }
        
        centerView.snp_updateConstraints { (make) in
            make.leading.equalTo(topLeftCorner.snp_trailing).priorityMedium()
            make.trailing.equalTo(topRightCorner.snp_leading).priorityMedium()
            make.top.equalTo(self.snp_top)
            make.bottom.equalTo(self.snp_bottom)
        }
        
        leftCenterView.snp_remakeConstraints { (make) in
            make.top.equalTo(topLeftCorner.snp_bottom)
            make.leading.equalTo(topLeftCorner.snp_leading)
            make.trailing.equalTo(topLeftCorner.snp_trailing)
            if isMyEvent {
                make.bottom.equalTo(bottomLeftCorner.snp_top).priorityMedium()
            } else {
                make.bottom.equalTo(self.snp_bottom)
            }
        }
        
        rightCenterView.snp_remakeConstraints { (make) in
            make.top.equalTo(topRightCorner.snp_bottom)
            make.leading.equalTo(topRightCorner.snp_leading)
            make.trailing.equalTo(topRightCorner.snp_trailing)
            if isMyEvent {
                make.bottom.equalTo(self.snp_bottom)
            } else {
                make.bottom.equalTo(bottomRightCorner.snp_top).priorityMedium()
            }
        }
        
        super.updateConstraints()
    }

}
