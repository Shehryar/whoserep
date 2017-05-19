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
    
    class func getMaxContentSizeThatFits(_ size: CGSize, with style: ComponentStyle) -> (CGSize, UIEdgeInsets) {
        var maxContentSize = size
        if maxContentSize.width == 0 {
            maxContentSize.width = CGFloat.greatestFiniteMagnitude
        }
        if maxContentSize.height == 0 {
            maxContentSize.height = CGFloat.greatestFiniteMagnitude
        }
        maxContentSize.width -= style.padding.left + style.padding.right
        maxContentSize.height -= style.padding.top + style.padding.bottom
        
        if maxContentSize.width <= 0 || maxContentSize.height <= 0 {
            return (.zero, style.padding)
        }
        return (maxContentSize, style.padding)
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
        
        let columnSizes = getColumnSizes(for: views, within: boundingRect.width)
        
        // Layout frames horizontally
        var maxFrameHeight: CGFloat = 0
        let top = boundingRect.minY
        var left = boundingRect.minX
        for (idx, view) in views.enumerated() {
            let margin = (view as? ComponentView)?.component?.style.margin ?? UIEdgeInsets.zero
            let alignment = (view as? ComponentView)?.component?.style.alignment ?? HorizontalAlignment.left
            
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
                left += margin.left
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
            
            if let style = (view as? ComponentView)?.component?.style {
                switch style.gravity {
                case .top:
                    // No change required
                    break
                    
                case .middle:
                    frame.origin.y = boundingRect.minY + floor((maxFrameHeight - frame.height) / 2.0)
                    
                    break
                    
                case .bottom:
                    frame.origin.y = boundingRect.minY + maxFrameHeight - frame.height - style.margin.bottom
                    break
                    
                case .fill:
                    frame.size.height = maxFrameHeight
                    break
                }
                frames[idx] = frame
                
                maxX = max(maxX, frame.maxX + style.margin.right)
                maxY = max(maxY, frame.maxY + style.margin.bottom)
            } else {
                maxX = max(maxX, frame.maxX)
                maxY = max(maxY, frame.maxY)
            }
        }
        
        return LayoutInfo(frames: frames, maxX: maxX, maxY: maxY)
    }
    
    private struct ColumnSize {
        let fittedSize: CGSize
        let maxColumnWidth: CGFloat
    }
    
    private class func getColumnSizes(for views: [UIView],
                                      within maxWidth: CGFloat) -> [ColumnSize] {
        var columnSizes = [ColumnSize]()
        for _ in views {
            columnSizes.append(ColumnSize(fittedSize: .zero, maxColumnWidth: 0))
        }
        
        var remainingWidth = getWidthMinusMargins(for: views, totalWidth: maxWidth)
        
        // Get the size for all weight=0 views
        for (idx, view) in views.enumerated() {
            let weight = (view as? ComponentView)?.component?.style.weight ?? 0
            if weight != 0 {
                continue
            }
            
            var size = view.sizeThatFits(CGSize(width: remainingWidth, height: 0))
            size.width = ceil(size.width)
            size.height = ceil(size.height)
            
            columnSizes[idx] = ColumnSize(fittedSize: size, maxColumnWidth: size.width)
            remainingWidth = max(0, remainingWidth - size.width)
        }
        //        printColumnSizes(columnSizes, text: "Fitted Sizes:")
        
        let weightedColumnWidths = getWeightedWidths(for: views, totalWidth: remainingWidth)
        for (idx, view) in views.enumerated() {
            let weight = (view as? ComponentView)?.component?.style.weight ?? 0
            if weight == 0 {
                continue
            }
            
            let columnWidth = weightedColumnWidths[idx]
            if columnWidth > 0 {
                var size = view.sizeThatFits(CGSize(width: columnWidth, height: 0))
                size.width = columnWidth// ceil(size.width)
                size.height = ceil(size.height)
                
                columnSizes[idx] = ColumnSize(fittedSize: size, maxColumnWidth: columnWidth)
            }
        }
        //        printColumnSizes(columnSizes, text: "Fitted and Weighted Sizes:")
        
        return columnSizes
    }
    
    private class func getWidthMinusMargins(for views: [UIView], totalWidth: CGFloat) -> CGFloat {
        var width = totalWidth
        for view in views {
            let margin = (view as? ComponentView)?.component?.style.margin ?? UIEdgeInsets.zero
            width = width - margin.left - margin.right
        }
        return max(0, width)
    }
    
    private class func getTotalWeight(for views: [UIView]) -> Int {
        var totalWeight: Int = 0
        for view in views {
            let weight = (view as? ComponentView)?.component?.style.weight ?? 0
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
        for _ in views {
            widths.append(0)
        }
        
        var totalAllocatedWidth: CGFloat = 0
        let widthPerWeight = getWidthPerWeight(for: views, totalWidth: totalWidth)
        for (idx, view) in views.enumerated() {
            let weight = (view as? ComponentView)?.component?.style.weight ?? 0
            if weight > 0 {
                let width = floor(CGFloat(weight) * widthPerWeight)
                widths[idx] = width
                totalAllocatedWidth += width
            }
        }
        
        let widthRoundingError = totalWidth - totalAllocatedWidth
        if widthRoundingError > 0 {
            for (idx, view) in views.enumerated().reversed() {
                let weight = (view as? ComponentView)?.component?.style.weight ?? 0
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


// MARK:- Vertical

extension ComponentLayoutEngine {
    
    class func getVerticalLayout(for views: [UIView], inside boundingRect: CGRect) -> ComponentLayoutEngine.LayoutInfo {
        var frames = [CGRect]()
        var maxX: CGFloat = boundingRect.minX
        var maxY: CGFloat = boundingRect.minY
        guard views.count > 0 else {
            return LayoutInfo(frames: frames, maxX: maxX, maxY: maxY)
        }
        
        let sizes = getRowSizes(for: views, within: boundingRect.size)
        
        var maxFrameHeight: CGFloat = 0
        var maxFrameWidth: CGFloat = 0
        var top = boundingRect.minY
        
        // Layout views vertically
        for (idx, view) in views.enumerated() {
            let margin = (view as? ComponentView)?.component?.style.margin ?? .zero
            let gravity = (view as? ComponentView)?.component?.style.gravity ?? .top
            
            let maxSize = sizes[idx].maxSize
            var size = sizes[idx].fittedSize

            // fittedSize < maxSize ==> Need to adjust for gravity within maxSize
            var offsetY: CGFloat = 0
            if size.height < maxSize.height {
                switch gravity {
                case .top: /* No-op */ break
                case.middle:
                    offsetY = floor((maxSize.height - size.height) / 2.0)
                    break
                    
                case .bottom:
                    offsetY = maxSize.height - size.height
                    break
                
                case .fill:
                    size.height = maxSize.height
                    break
                }
            }
            
            // Create frame
            top += margin.top
            let frame = CGRect(x: boundingRect.minX, y: top + offsetY, width: size.width, height: size.height)
            frames.append(frame)
            top += size.height + margin.bottom
            
            maxFrameHeight = max(maxFrameHeight, size.height)
            maxFrameWidth = max(maxFrameWidth, size.width)
        }
        // Return if no content size
        guard maxFrameHeight > 0 && maxFrameWidth > 0 else {
            return LayoutInfo(frames: frames, maxX: maxX, maxY: maxY)
        }
        
        
        // Adjust frames horizontally
        for (idx, view) in views.enumerated() {
            let alignment = (view as? ComponentView)?.component?.style.alignment ?? .left
            let margin = (view as? ComponentView)?.component?.style.margin ?? .zero
            
            var frame = frames[idx]
            
            let maxDisplayWidth = boundingRect.width - margin.left - margin.right
            switch alignment {
            case .left:
                frame.origin.x = boundingRect.minX + margin.left
                break
                
            case .center:
                frame.origin.x = boundingRect.minX + margin.left + floor((maxDisplayWidth - frame.size.width) / 2.0)
                break
                
            case .right:
                frame.origin.x = boundingRect.maxX - frame.size.width - margin.right
                break
                
            case .fill:
                frame.origin.x = boundingRect.minX + margin.left
                frame.size.width = boundingRect.width - margin.left - margin.right
                break
            }
            frames[idx] = frame
            
            maxX = max(maxX, frame.maxX + margin.right)
            maxY = max(maxY, frame.maxY + margin.bottom)
        }
    
        return LayoutInfo(frames: frames, maxX: maxX, maxY: maxY)
    }
    
    private struct RowSize {
        let fittedSize: CGSize
        let maxSize: CGSize
    }
    
    private class func getRowSizes(for views: [UIView], within maxSize: CGSize) -> [RowSize] {
        // Initialize sizes to (.zero, .zero)
        var sizes = [RowSize]()
        for _ in views {
            sizes.append(RowSize(fittedSize: .zero, maxSize: .zero))
        }
        
        // Get available height after margins are subtracted
        var remainingHeight = maxSize.height
        for view in views {
            let margin = (view as? ComponentView)?.component?.style.margin ?? .zero
            remainingHeight -= margin.top + margin.bottom
        }
        guard remainingHeight > 0 else {
            return sizes
        }
        
        // Update the size for all views with weight==0 (size-to-fit)
        for (idx, view) in views.enumerated() {
            let weight = (view as? ComponentView)?.component?.style.weight ?? 0
            guard weight == 0 else {
                continue
            }
            let margin = (view as? ComponentView)?.component?.style.margin ?? .zero
            
            let maxWidth = maxSize.width - margin.left - margin.right
            let maxSize = CGSize(width: maxWidth, height: remainingHeight)
            var fittedSize = view.sizeThatFits(maxSize)
            fittedSize.width = ceil(fittedSize.width)
            fittedSize.height = ceil(fittedSize.height)
            
            sizes[idx] = RowSize(fittedSize: fittedSize, maxSize: fittedSize)
            
            remainingHeight -= fittedSize.height
            if remainingHeight <= 0 {
                return sizes
            }
        }
        
        // Get the total weight of all views
        var totalWeightOfViews: Int = 0
        for view in views {
            totalWeightOfViews += (view as? ComponentView)?.component?.style.weight ?? 0
        }
        guard totalWeightOfViews > 0 else {
            // No other views to size
            return sizes
        }
        
        // Calculate height per weight, and account for rounding errors
        let totalHeightAvailableForWeightedViews = remainingHeight
        let heightPerWeight: CGFloat = floor(totalHeightAvailableForWeightedViews / CGFloat(totalWeightOfViews))
        guard heightPerWeight > 0 else {
            return sizes
        }
        let totalHeightUsedByRoundedHeights = heightPerWeight * CGFloat(totalWeightOfViews)
        var initialRoundingErrorAdjustment = max(0, totalHeightAvailableForWeightedViews - totalHeightUsedByRoundedHeights)
        
        // Calculate size for all views with weight != 0
        for (idx, view) in views.enumerated() {
            let weight = (view as? ComponentView)?.component?.style.weight ?? 0
            guard weight > 0 else {
                continue
            }
            let margin = (view as? ComponentView)?.component?.style.margin ?? .zero
            
            var maxHeight = CGFloat(weight) * heightPerWeight
            if initialRoundingErrorAdjustment > 0 {
                maxHeight += initialRoundingErrorAdjustment
                initialRoundingErrorAdjustment = 0
            }
            let maxWidth = maxSize.width - margin.left - margin.right
            let maxSize = CGSize(width: maxWidth, height: maxHeight)
            var fittedSize = view.sizeThatFits(maxSize)
            fittedSize.width = ceil(fittedSize.width)
            fittedSize.height = ceil(fittedSize.height)
            
            sizes[idx] = RowSize(fittedSize: fittedSize, maxSize: maxSize)
        }
        
        return sizes
    }
}
