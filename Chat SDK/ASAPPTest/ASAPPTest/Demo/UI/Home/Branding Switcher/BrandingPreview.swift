//
//  BrandingPreview.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/1/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BrandingPreview: UIView {

    static let defaultHeight: CGFloat = 44.0
    
    var onTap: (() -> Void)?
    
    var brandingType: BrandingType? {
        didSet {
            if let brandingType = brandingType {
                branding = Branding(brandingType: brandingType)
            }
        }
    }
    
    private var branding: Branding = Branding(brandingType: .asapp) {
        didSet {
            if branding.colors.navBarColor.isEqual(UIColor.black)
                || branding.colors.navBarColor.isEqual(UIColor.white) {
                backgroundColor =  UIColor.clear
            } else {
                backgroundColor = branding.colors.navBarColor
            }
        
            backgroundView.effect = branding.colors.isDarkNavStyle
                ? UIBlurEffect(style: .dark)
                : UIBlurEffect(style: .light)
            
            imageView.image = UIImage(named: branding.logoImageName)
            
            setNeedsLayout()
        }
    }
    
    private let separatorView = UIView()
    
    private let backgroundView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private let imageView = UIImageView()
    
    private let highlightView = UIView()
    
    // MARK: Initialization
    
    func commonInit() {
        clipsToBounds = true
        
        addSubview(backgroundView)
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        separatorView.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        separatorView.alpha = 0.5
        addSubview(separatorView)
        
        highlightView.backgroundColor = UIColor.black
        highlightView.alpha = 0.0
        addSubview(highlightView)
        
        isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK:- Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        highlightView.frame = bounds
        
        let imageTop = floor((bounds.height - branding.logoImageSize.height) / 2.0)
        let imageLeft = floor((bounds.width - branding.logoImageSize.width) / 2.0)
        imageView.frame = CGRect(x: imageLeft, y: imageTop, width: branding.logoImageSize.width, height: branding.logoImageSize.height)
        
        let separatorStroke: CGFloat = 1.0
        let separatorTop: CGFloat = bounds.height - separatorStroke
        separatorView.frame = CGRect(x: 0.0, y: separatorTop, width: bounds.width, height: separatorStroke)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: BrandingPreview.defaultHeight)
    }
    
    // MARK:- Actions
    
    func didTap() {
        if let onTap = onTap {
            onTap()
        }
    }
    
    func setHighlightViewVisible(_ visible: Bool, animated: Bool) {
        let alpha: CGFloat = visible ? 0.1 : 0.0
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.highlightView.alpha = alpha
            })
        } else {
            self.highlightView.alpha = alpha
        }
    }
    
    // MARK:- Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        setHighlightViewVisible(true, animated: false)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if !touchIsInside(view: self, touches: touches) {
            setHighlightViewVisible(false, animated: false)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        setHighlightViewVisible(false, animated: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if touchIsInside(view: self, touches: touches) {
            if let onTap = onTap {
                onTap()
            }
            setHighlightViewVisible(false, animated: true)
        } else {
            setHighlightViewVisible(false, animated: false)
        }
     
        
    }
    
    // MARK:- Touch Helpers
    
    func getTouchPointIn(_ view: UIView, touches: Set<UITouch>) -> CGPoint? {
        if let touch = touches.first {
            return touch.location(in: view)
        }
        return nil
    }
    
    func touchIsInside(view: UIView, touches: Set<UITouch>) -> Bool {
        if let touchPoint = getTouchPointIn(view, touches: touches) {
            return view.bounds.contains(touchPoint)
        }
        return false
    }
}
