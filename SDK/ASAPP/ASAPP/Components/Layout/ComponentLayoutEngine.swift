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
            var size = view.sizeThatFits(CGSize(width: width, height: 0))
            size.width = ceil(size.width)
            size.height = ceil(size.height)
            
            if size.height > 0 {
                top += margin.top
            }
            let frame = CGRect(x: left, y: top, width: size.width, height: size.height)
            if size.height > 0 {
                top += size.height + margin.bottom
            }
            
            frames.append(frame)
        }
        
        // Adjust horizontally, if needed
        for (idx, view) in views.enumerated() {
            var frame = frames[idx]
            let margin = (view as? ComponentView)?.component?.layout.margin ?? UIEdgeInsets.zero
            
            let maxWidth = boundingRect.width - margin.left - margin.right
            if frame.width >= maxWidth {
                continue
            }
            
            let alignment = (view as? ComponentView)?.component?.layout.alignment ?? .left
            switch alignment {
            case .left:
                // No-op
                break
                
            case .center:
                frame.origin.x = frame.minX + floor((maxWidth - frame.width) / 2.0)
                break
                
            case .right:
                frame.origin.x = frame.minX + maxWidth - frame.width
                break
                
            case .fill:
                frame.size.width = maxWidth
                break
            }
            frames[idx] = frame
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
//        let totalColumnsWidth = getWidthMinusMargins(for: views, totalWidth: boundingRect.width)
//        let columnWidth = floor(totalColumnsWidth / CGFloat(views.count))
  
        let columnSizes = getColumnSizes(for: views, within: boundingRect.width)
        
        // Layout frames horizontally
        var maxFrameHeight: CGFloat = 0
        var top = boundingRect.minY
        var left = boundingRect.minX
        for (idx, view) in views.enumerated() {
            let margin = (view as? ComponentView)?.component?.layout.margin ?? UIEdgeInsets.zero
            let alignment = (view as? ComponentView)?.component?.layout.alignment ?? HorizontalAlignment.left
            
//            var size = view.sizeThatFits(CGSize(width: columnWidth, height: 0))
            var size = columnSizes[idx].fittedSize
            let columnWidth = columnSizes[idx].maxColumnWidth
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
                frame = CGRect(x: left + offsetX, y: top, width: size.width, height: size.height)
                left += columnWidth + margin.right
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
        
        print("Horizontal Frames: \(frames)")
        
        return LayoutInfo(frames: frames, maxX: maxX, maxY: maxY)
    }
    
    private struct ColumnSize {
        let fittedSize: CGSize
        let maxColumnWidth: CGFloat
    }
    
    private class func getColumnSizes(for views: [UIView],
                                      within maxWidth: CGFloat) -> [ColumnSize] {
        var columnSizes = [ColumnSize]()
        for view in views {
            columnSizes.append(ColumnSize(fittedSize: .zero, maxColumnWidth: 0))
        }
        
        var remainingWidth = getWidthMinusMargins(for: views, totalWidth: maxWidth)
        
        print("\nGetting column sizes for totalWidth: \(maxWidth), minus margins: \(remainingWidth)")
        
        // Get the size for all weight=0 views
        for (idx, view) in views.enumerated() {
            let weight = (view as? ComponentView)?.component?.layout.weight ?? 0
            if weight != 0 {
                continue
            }
            
            var size = view.sizeThatFits(CGSize(width: remainingWidth, height: 0))
            size.width = ceil(size.width)
            size.height = ceil(size.height)
            
            columnSizes[idx] = ColumnSize(fittedSize: size, maxColumnWidth: size.width)
            remainingWidth = max(0, remainingWidth - size.width)
        }
        printColumnSizes(columnSizes, text: "Fitted Sizes:")
        
        let weightedColumnWidths = getWeightedWidths(for: views, totalWidth: remainingWidth)
        for (idx, view) in views.enumerated() {
            let weight = (view as? ComponentView)?.component?.layout.weight ?? 0
            if weight == 0 {
                continue
            }
            
            let columnWidth = weightedColumnWidths[idx]
            if columnWidth > 0 {
                var size = view.sizeThatFits(CGSize(width: columnWidth, height: 0))
                size.width = ceil(size.width)
                size.height = ceil(size.height)
                
                columnSizes[idx] = ColumnSize(fittedSize: size, maxColumnWidth: columnWidth)
            }
        }
        printColumnSizes(columnSizes, text: "Fitted and Weighted Sizes:")
        
        return columnSizes
    }
    
    private class func getWidthMinusMargins(for views: [UIView], totalWidth: CGFloat) -> CGFloat {
        var width = totalWidth
        for view in views {
            let margin = (view as? ComponentView)?.component?.layout.margin ?? UIEdgeInsets.zero
            width -= margin.left + margin.right
        }
        return max(0, width)
    }
    
    private class func getTotalWeight(for views: [UIView]) -> Int {
        var totalWeight: Int = 0
        for view in views {
            let weight = (view as? ComponentView)?.component?.layout.weight ?? 0
            totalWeight += weight
        }
        return totalWeight
    }
    
    private class func getWidthPerWeight(for views: [UIView], totalWidth: CGFloat) -> CGFloat {
        let totalWeight = getTotalWeight(for: views)
        var widthPerWeight = totalWidth
        if totalWeight > 0 {
            widthPerWeight = floor(totalWidth / CGFloat(totalWeight))
        }
        return widthPerWeight
    }
    
    private class func getWeightedWidths(for views: [UIView], totalWidth: CGFloat) -> [CGFloat] {
        var widths = [CGFloat]()
        for view in views {
            widths.append(0)
        }
        
        var totalAllocatedWidth: CGFloat = 0
        let widthPerWeight = getWidthPerWeight(for: views, totalWidth: totalWidth)
        for (idx, view) in views.enumerated() {
            let weight = (view as? ComponentView)?.component?.layout.weight ?? 0
            if weight > 0 {
                let width = floor(CGFloat(weight) * widthPerWeight)
                widths[idx] = width
                totalAllocatedWidth += width
            }
        }
        
        let widthRoundingError = totalWidth - totalAllocatedWidth
        if widthRoundingError > 0 {
            for (idx, view) in views.enumerated().reversed() {
                let weight = (view as? ComponentView)?.component?.layout.weight ?? 0
                if weight > 0 {
                    var width = widths[idx]
                    width += widthRoundingError
                    widths[idx] = width
                    break
                }
            }
        }
        
        return widths
    }
    
    private class func printColumnSizes(_ sizes: [ColumnSize], text: String) {
        var columnDescriptions = [String]()
        for size in sizes {
            let description = "max: \(size.maxColumnWidth), size: \(size.fittedSize)"
            columnDescriptions.append(description)
        }
        
        DebugLog.i(caller: self, "\n\(text): [\n  \(columnDescriptions.joined(separator: "\n  "))\n]")
    }
}
