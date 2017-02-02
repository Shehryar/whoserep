//
//  BrandingSwitcherView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/2/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BrandingSwitcherView: UIView {
   
    var didSelectBrandingType: ((_ type: BrandingType) -> Void)? {
        didSet {
            brandingPreviewListView.didSelectBrandingType = didSelectBrandingType
        }
    }
    
    private(set) var switcherViewHidden = true
    
    private let brandingPreviewListView = BrandingPreviewListView()
    
    private let backgroundOverlayView = UIView()
    
    private var brandingPreviewSize: CGSize = .zero
    
    // MARK: Initialization
    
    func commonInit() {
        isUserInteractionEnabled = false
        
        backgroundOverlayView.backgroundColor = UIColor.black
        backgroundOverlayView.alpha = 0.0
        backgroundOverlayView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                          action: #selector(BrandingSwitcherView.didTapOverlayView)))
        addSubview(backgroundOverlayView)
        
        addSubview(brandingPreviewListView)
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
        
        backgroundOverlayView.frame = bounds
        
        let size = calculatePreviewListSize()
        brandingPreviewListView.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        brandingPreviewListView.center = getPreviewListCenter(whenHidden: switcherViewHidden)
    }
    
    func getPreviewListCenter(whenHidden hidden: Bool) -> CGPoint {
        var center = CGPoint(x: bounds.midX, y: bounds.midY)
        if switcherViewHidden {
            let size = calculatePreviewListSize()
            center.y = floor(-size.height / 2.0 - 64)
        }
        
        return center
    }
    
    private func calculatePreviewListSize() -> CGSize {
        let width = floor(min(320, bounds.width * 0.8))
        let height = ceil(brandingPreviewListView.sizeThatFits(CGSize(width: width, height: 0)).height)
        return CGSize(width: width, height: height)
    }
    
    // MARK:- Actions
    
    func didTapOverlayView() {
        setSwitcherViewHidden(true, animated: true)
    }
    
    func setSwitcherViewHidden(_ hidden: Bool, animated: Bool) {
        if hidden == switcherViewHidden {
            return
        }
        switcherViewHidden = hidden
        
        func updateBlock() {
            self.brandingPreviewListView.center = getPreviewListCenter(whenHidden: switcherViewHidden)
            self.backgroundOverlayView.alpha = switcherViewHidden ? 0.0 : 0.4
            self.isUserInteractionEnabled = !switcherViewHidden
        }
        
        if animated {
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.75,
                           initialSpringVelocity: 0.0,
                           options: .curveEaseInOut,
                           animations: updateBlock,
                           completion: nil)
        } else {
            updateBlock()
        }
    }
}
