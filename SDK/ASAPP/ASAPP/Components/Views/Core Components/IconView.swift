//
//  IconView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class IconView: UIView, ComponentView {

    let imageView = UIImageView()
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            if let iconItem = iconItem {
                if let tintColor = iconItem.style.color {
                    imageView.image = iconItem.icon.getImage()?.tinted(tintColor)
                } else {
                    imageView.image = iconItem.icon.getImage()
                }
            } else {
                imageView.image = nil
            }
        }
    }
    
    var iconItem: IconItem? {
        return component as? IconItem
    }
    
    weak var interactionHandler: InteractionHandler?

    // MARK: Init
    
    func commonInit() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        addSubview(imageView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding = iconItem?.style.padding ?? UIEdgeInsets.zero
        imageView.frame = UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let iconItem = iconItem else {
            return .zero
        }
        let style = iconItem.style
        let width = style.width > 0 ? style.width : IconItem.defaultWidth
        let height = style.height > 0 ? style.height : IconItem.defaultHeight
        let padding = style.padding
        
        let sizeWithPadding = CGSize(width: width + padding.left + padding.right,
                                     height: height + padding.top + padding.bottom)
        return sizeWithPadding
    }
}
