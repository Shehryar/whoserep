//
//  BrandingSwitcherView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BrandingSwitcherView: UIView {

    var didSelectBrandingType: ((_ type: BrandingType) -> Void)?
    
    var expandedHeight: CGFloat = 200.0

    private(set) var expanded: Bool = false
    
    // MARK: Private Properties
    
    private let scrollView = UIScrollView()
    
    private var brandingPreviews = [BrandingPreview]()
    
    private let shadowView = UIView()
    
    // MARK:- Initialization
    
    func commonInit() {
        clipsToBounds = false
        
        
        scrollView.alwaysBounceVertical = false
        addSubview(scrollView)
        
        for type in BrandingType.all {
            let brandingPreview = BrandingPreview()
            brandingPreview.brandingType = type
            brandingPreview.onTap = { [weak self] in
                if let didSelectBrandingType = self?.didSelectBrandingType {
                    didSelectBrandingType(type)
                }
            }
            scrollView.addSubview(brandingPreview)
            brandingPreviews.append(brandingPreview)
        }
        
        shadowView.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        shadowView.alpha = 0.5
        addSubview(shadowView)

        expandedHeight = BrandingPreview.defaultHeight * CGFloat(brandingPreviews.count)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK:- Properties
    
    func setExpanded(_ expanded: Bool, animated: Bool) {
        self.expanded = expanded
        
        func frameUpdateBlock() {
            let height = expanded ? expandedHeight : 0.0
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: height)
            updateFrames()
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: frameUpdateBlock)
        } else {
            frameUpdateBlock()
        }
    }

    // MARK:- Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func updateFrames() {
        scrollView.frame = bounds
        
        var contentTop: CGFloat = 0.0
        for brandingPreview in brandingPreviews {
            let height = ceil(brandingPreview.sizeThatFits(CGSize(width: bounds.width, height: 0.0)).height)
            brandingPreview.frame = CGRect(x: 0.0, y: contentTop, width: bounds.width, height: height)
            contentTop = brandingPreview.frame.maxY
        }
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: contentTop)
        
        let shadowViewHeight: CGFloat = 1.0
        let shadowViewTop = bounds.height - shadowViewHeight
        shadowView.frame = CGRect(x: 0, y: shadowViewTop, width: bounds.width, height: shadowViewHeight)
    }
}
