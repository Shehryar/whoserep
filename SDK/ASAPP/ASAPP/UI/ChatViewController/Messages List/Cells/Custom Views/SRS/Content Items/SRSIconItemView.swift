//
//  SRSIconItemView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSIconItemView: UIView {

    var iconItem: SRSIconItem? {
        didSet {
            updateDisplay()
        }
    }
    
    let iconWidth: CGFloat = 36.0
    
    let contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 8, right: 0)
    
    private let imageView = UIImageView()
    
    // MARK:- Initialization
    
    func commonInit() {
        backgroundColor = ASAPP.styles.colors.backgroundSecondary
        
        imageView.backgroundColor = ASAPP.styles.colors.backgroundSecondary
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
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

    // MARK:- Display
    
    func updateDisplay() {
        if let image = iconItem?.getImage() {
            imageView.image = image.tinted(UIColor(red:0.533, green:0.541, blue:0.561, alpha:1.000))
        } else {
            imageView.image = nil
        }
        setNeedsLayout()
    }
    
    // MARK:- Layout
    
    private func getIconHeightThatFits(_ size: CGSize) -> CGFloat {
        let maxHeight = size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude
        
        var height: CGFloat = 0.0
        if let image = imageView.image {
            if image.size.width > 0 {
                height = ceil(iconWidth * image.size.height / image.size.width)
            } else {
                height = iconWidth
            }
        }
        
        return min(maxHeight, height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconHeight = getIconHeightThatFits(bounds.size)
        let iconLeft = floor((bounds.width - iconWidth) / 2.0)
        imageView.frame = CGRect(x: iconLeft, y: contentInset.top, width: iconWidth, height: iconHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let iconHeight = getIconHeightThatFits(size)
        let totalHeight = iconHeight > 0 ? iconHeight + contentInset.top + contentInset.bottom : 0
        return CGSize(width: size.width, height: totalHeight)
    }
}
