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
    }
    
    override func updateFrames() {
        let padding = imageItem?.style.padding ?? .zero
        imageView.frame = UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let imageItem = imageItem else {
            return .zero
        }
        
        let style = imageItem.style
        let padding = style.padding
        
        if style.height > 0 && style.width > 0 {
            return CGSize(width: style.width + padding.horizontal, height: style.height + padding.vertical)
        }
        
        let originalSize = imageView.image?.size ?? .zero
        var height: CGFloat? = style.height > 0 ? style.height : nil
        var width: CGFloat? = style.width > 0 ? style.width : nil
        
        if let height = height {
            let aspectAdjustedWidth = height * (originalSize.width / max(1, originalSize.height))
            width = min(size.width, aspectAdjustedWidth)
        } else if let width = width {
            let aspectAdjustedHeight = width * (originalSize.height / max(1, originalSize.width))
            height = min(size.height, aspectAdjustedHeight)
        } else {
            width = min(size.width, originalSize.width)
            height = min(size.height, originalSize.height)
        }
        
        return CGSize(width: (width ?? 0) + padding.horizontal, height: (height ?? 0) + padding.vertical)
    }
}
