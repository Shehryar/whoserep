//
//  ComponentLayoutEngine.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentLayoutEngine: NSObject {
    
    struct LayoutInfo {
        let frames: [CGRect]
        let maxX: CGFloat
        let maxY: CGFloat
    }
    
    // Vertical Layout
    
    class func getVerticalFrames(for views: [UIView],
                                 inside boundingRect: CGRect) -> [CGRect] {
        var frames = [CGRect]()

        var top: CGFloat = boundingRect.minY
        for view in views {
            let layout = (view as? ComponentView)?.component?.layout
            let margin = layout?.margin ?? UIEdgeInsets.zero
            
            let left = boundingRect.minX + margin.left
            let width = boundingRect.width - margin.left - margin.right
            let height = ceil(view.sizeThatFits(CGSize(width: width, height: 0)).height)
            
            if height > 0 {
                top += margin.top
            }
            let frame = CGRect(x: left, y: top, width: width, height: height)
            if height > 0 {
                top += height + margin.bottom
            }
            
            frames.append(frame)
        }
        
        return frames
    }
    
    // Adjusting Frames
    
    class func getAdjustedFrames(_ frames: [CGRect],
                                 for gravity: VerticalAlignment,
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
        case .top, .fill:
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

// MARK:- Horizontal

extension ComponentLayoutEngine {
    
    class func getHorizontalLayout(for views: [UIView], inside boundingRect: CGRect) -> ComponentLayoutEngine.LayoutInfo {
        var frames = [CGRect]()
        var maxX: CGFloat = boundingRect.minX
        var maxY: CGFloat = boundingRect.minY
        guard views.count > 0 else {
            return LayoutInfo(frames: frames, maxX: maxX, maxY: maxY)
        }
        
        // Only even columns for now
        let totalColumnsWidth = getWidthMinusMargins(for: views, startingWidth: boundingRect.width)
        let columnWidth = floor(totalColumnsWidth / CGFloat(views.count))
        
        // Layout frames horizontally
        var maxFrameHeight: CGFloat = 0
        var top = boundingRect.minY
        var left = boundingRect.minX
        for view in views {
            let margin = (view as? ComponentView)?.component?.layout.margin ?? UIEdgeInsets.zero
            let alignment = (view as? ComponentView)?.component?.layout.alignment ?? HorizontalAlignment.left
            
            var size = view.sizeThatFits(CGSize(width: columnWidth, height: 0))
            var offsetX: CGFloat = 0
            if size.width < columnWidth {
                switch alignment {
                case .left:
                    // No adjustment needed
                    break
                    
                case .center:
                    offsetX = floor((columnWidth - size.width) / 2.0)
                    break
                    
                case .right:
                    offsetX = columnWidth - size.width
                    break
                    
                case .fill:
                    size.width = columnWidth
                    break
                }
            }
            
            let frame: CGRect
            if size.width > 0 && size.height > 0 {
                left += margin.left
                frame = CGRect(x: left + offsetX, y: top, width: size.width, height: size.height)
                left += size.width + margin.right
            } else {
                frame = CGRect(x: left, y: top, width: 0, height: 0)
            }
            frames.append(frame)
            
            maxFrameHeight = max(frame.height, maxFrameHeight)
        }
        guard maxFrameHeight > 0 else {
            return LayoutInfo(frames: frames, maxX: maxX, maxY: maxY)
        }
        
        // Adjust frames vertically, if necessary
        for (idx, view) in views.enumerated() {
            var frame = frames[idx]
            
            if let layout = (view as? ComponentView)?.component?.layout {
                switch layout.gravity {
                case .top:
                    // No change required
                    break
                    
                case .middle:
                    frame.origin.y = boundingRect.minY + floor((maxFrameHeight - frame.height) / 2.0)
                   
                    break
                    
                case .bottom:
                    frame.origin.y = boundingRect.minY + maxFrameHeight - frame.height - layout.margin.bottom
                    break
                    
                case .fill:
                    frame.size.height = maxFrameHeight
                    break
                }
                frames[idx] = frame
                
                maxX = max(maxX, frame.maxX + layout.margin.right)
                maxY = max(maxY, frame.maxY + layout.margin.bottom)
            } else {
                maxX = max(maxX, frame.maxX)
                maxY = max(maxY, frame.maxY)
            }
        }
        
        print("Horizontal Frames:\n\(frames)\nmaxX: \(maxX)\nmaxY: \(maxY)")
        
        return LayoutInfo(frames: frames, maxX: maxX, maxY: maxY)
    }
    
    private class func getWidthMinusMargins(for views: [UIView], startingWidth: CGFloat) -> CGFloat {
        var width = startingWidth
        for view in views {
            let margin = (view as? ComponentView)?.component?.layout.margin ?? UIEdgeInsets.zero
            width -= margin.left + margin.right
        }
        return max(0, width)
    }
}
