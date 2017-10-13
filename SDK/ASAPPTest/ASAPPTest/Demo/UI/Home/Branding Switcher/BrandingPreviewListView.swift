//
//  BrandingPreviewListView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BrandingPreviewListView: UIView {

    var didSelectBrandingType: ((_ type: BrandingType) -> Void)?
    
    private let cornerRadius: CGFloat = 16.0
    
    private let containerView = UIView()
    
    private var brandingPreviews = [BrandingPreview]()
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = UIColor.clear
        
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 1)
        
        containerView.clipsToBounds = true
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        containerView.layer.allowsEdgeAntialiasing = true
        addSubview(containerView)
        
        for type in BrandingType.all {
            let brandingPreview = BrandingPreview()
            brandingPreview.brandingType = type
            brandingPreview.onTap = { [weak self] in
                if let didSelectBrandingType = self?.didSelectBrandingType {
                    didSelectBrandingType(type)
                }
            }
            containerView.addSubview(brandingPreview)
            brandingPreviews.append(brandingPreview)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.frame = bounds
        layer.shadowPath = UIBezierPath(roundedRect: containerView.frame,
                                        cornerRadius: cornerRadius).cgPath
        
        var contentTop: CGFloat = 0.0
        for brandingPreview in brandingPreviews {
            let height = ceil(brandingPreview.sizeThatFits(CGSize(width: bounds.width, height: 0.0)).height)
            brandingPreview.frame = CGRect(x: 0.0, y: contentTop, width: bounds.width, height: height)
            contentTop = brandingPreview.frame.maxY
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: BrandingPreview.defaultHeight * CGFloat(brandingPreviews.count))
    }
}
