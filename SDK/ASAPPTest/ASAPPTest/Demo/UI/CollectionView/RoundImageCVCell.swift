//
//  RoundImageCVCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 6/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RoundImageCVCell: UICollectionViewCell {

    static let reuseId = "\(String(describing: RoundImageCVCell.self))_reuse_id"
    
    let imageView = UIImageView()
    
    var shouldHighlightImageBorder: Bool = false {
        didSet {
            updateBorder()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateBorder()
        }
    }
    
    // MARK: Init
    
    func commonInit() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        updateBorder()
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
        
        imageView.frame = bounds
        imageView.layer.cornerRadius = bounds.height / 2.0
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let minSize = min(size.width, size.height)
        if minSize > UIScreen.main.bounds.width || minSize > UIScreen.main.bounds.height {
            return CGSize(width: 50, height: 50)
        }
        return CGSize(width: minSize, height: minSize)
    }

    // MARK: Border
    
    func updateBorder() {
        
        
        let color: UIColor
        if isHighlighted || shouldHighlightImageBorder {
            color = AppSettings.shared.branding.colors.accentColor
            imageView.layer.borderWidth = 3.0
        } else {
            color = AppSettings.shared.branding.colors.secondaryTextColor
            imageView.layer.borderWidth = 2.0
        }
        imageView.layer.borderColor = color.cgColor
        imageView.layer.rasterizationScale = UIScreen.main.scale
        imageView.layer.shouldRasterize = true
    }
}
