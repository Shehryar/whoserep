//
//  ComponentLayoutEngine.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentLayoutEngine: NSObject {

    enum LayoutGravity {
        case top
        case middle
        case bottom
    }
    
    class func getVerticalFrames(for views: [ComponentView],
                                 inside boundingRect: CGRect) -> [CGRect] {
        var frames = [CGRect]()

        var top: CGFloat = boundingRect.minY
        for view in views {
            guard let layout = view.component?.layout else {
                let frame = CGRect(x: boundingRect.minX, y: top,
                                   width: boundingRect.width, height: 0)
                frames.append(frame)
                continue
            }
            
            let left = boundingRect.minX + layout.margin.left
            let width = boundingRect.width - layout.margin.left - layout.margin.right
            let height = ceil(view.sizeThatFits(CGSize(width: width, height: 0)).height)
            
            if height > 0 {
                top += layout.margin.top
            }
            let frame = CGRect(x: left, y: top, width: width, height: height)
            if height > 0 {
                top += height + layout.margin.bottom
            }
            
            frames.append(frame)
        }
        
        return frames
    }
    
    class func getAdjustedFrames(_ frames: [CGRect],
                                 for gravity: LayoutGravity,
                                 inside boundingRect: CGRect) -> [CGRect] {
        guard !frames.isEmpty else {
            return frames
        }
        
        // Find min/max y values
        var maxY: CGFloat = 0
        var minY: CGFloat = CGFloat.greatestFiniteMagnitude
        for frame in frames {
            if frame.minY < minY {
                minY = frame.minY
            }
            if frame.maxY > maxY {
                maxY = frame.maxY
            }
        }
        guard minY != CGFloat.greatestFiniteMagnitude else {
            return frames
        }
        
        // Calculate required adjustment
        var verticalAdjustment: CGFloat = 0
        switch gravity {
        case .top:
            if minY != boundingRect.minY {
                verticalAdjustment = boundingRect.minY - minY
            }
            break
            
        case .middle:
            let contentHeight = max(0, maxY - minY)
            verticalAdjustment = floor((boundingRect.height - contentHeight) / 2.0)
            break
            
        case .bottom:
            if maxY != boundingRect.maxY {
                verticalAdjustment = boundingRect.maxY - maxY
            }
            break
        }
        guard verticalAdjustment != 0 else {
            return frames
        }
        
        // Adjust frames based on calculation
        var adjustedFrames = [CGRect]()
        for frame in frames {
            var adjustedFrame = frame
            adjustedFrame.origin.y += verticalAdjustment
            adjustedFrames.append(adjustedFrame)
        }
        
        return adjustedFrames
    }
    
}
