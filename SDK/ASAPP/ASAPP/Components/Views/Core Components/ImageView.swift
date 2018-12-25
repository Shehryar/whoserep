//
//  ImageView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/16/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class ImageView: BaseComponentView {
    let imageView = UIImageView()
    
    override var component: Component? {
        didSet {
            if let imageItem = imageItem {
                accessibilityLabel = imageItem.descriptionText
                
                switch imageItem.scaleType {
                case .aspectFit:
                    imageView.contentMode = .scaleAspectFit
                case .aspectFill:
                    imageView.contentMode = .scaleAspectFill
                }
                
                imageView.sd_setImage(with: imageItem.url) { [weak self] (_, _, _, _) in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.contentHandler?.componentView(strongSelf, didUpdateContent: nil, requiresLayoutUpdate: true)
                }
            }
        }
    }
    
    var imageItem: ImageItem? {
        return component as? ImageItem
    }
    
    override func commonInit() {
        super.commonInit()
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        isAccessibilityElement = true
    }
    
    override func updateFrames() {
        let padding = imageItem?.style.padding ?? .zero
        imageView.frame = bounds.inset(by: padding)
    }
    
    override func sizeThatFits(_ maxSize: CGSize) -> CGSize {
        guard let imageItem = imageItem else {
            return .zero
        }
        
        let style = imageItem.style
        let padding = style.padding
        
        if style.height > 0 && style.width > 0 {
            return CGSize(width: style.width + padding.horizontal, height: style.height + padding.vertical)
        }
        
        let originalSize = imageView.image?.size ?? .zero
        var height: CGFloat? = (style.height > 0 ? style.height : nil) ?? (maxSize.height != .greatestFiniteMagnitude ? maxSize.height : nil)
        var width: CGFloat? = (style.width > 0 ? style.width : nil) ?? (maxSize.width != .greatestFiniteMagnitude ? maxSize.width : nil)
        
        if let maxHeight = height, let maxWidth = width {
            let aspectAdjustedWidth = maxHeight * (originalSize.width / max(1, originalSize.height))
            let aspectAdjustedHeight = maxWidth * (originalSize.height / max(1, originalSize.width))
            if aspectAdjustedWidth > maxWidth {
                height = aspectAdjustedHeight
                width = maxWidth
            } else if aspectAdjustedHeight > maxHeight {
                height = maxHeight
                width = aspectAdjustedWidth
            }
        } else if let maxHeight = height {
            let aspectAdjustedWidth = maxHeight * (originalSize.width / max(1, originalSize.height))
            width = min(maxSize.width, aspectAdjustedWidth)
        } else if let maxWidth = width {
            let aspectAdjustedHeight = maxWidth * (originalSize.height / max(1, originalSize.width))
            height = min(maxSize.height, aspectAdjustedHeight)
        } else {
            width = min(maxSize.width, originalSize.width)
            height = min(maxSize.height, originalSize.height)
        }
        
        return CGSize(width: (width ?? 0) + padding.horizontal, height: (height ?? 0) + padding.vertical)
    }
}
