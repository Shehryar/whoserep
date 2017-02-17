//
//  SRSInlineButtonsView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSInlineButtonsView: UIView, ASAPPStyleable {

    var buttonItems: [SRSButtonItem]? {
        didSet {
            reloadButtonItemViews()
        }
    }
    
    var onButtonItemTap: ((_ buttonItem: SRSButtonItem) -> Void)?
    
    private var buttonItemViews = [SRSButtonItemView]()
    
    // MARK: Initialization
    
    func commonInit() {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK:- ASAPPStyleable
    
    fileprivate(set) var styles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        
        for buttonItemView in buttonItemViews {
            buttonItemView.applyStyles(styles)
        }
        
        setNeedsLayout()
    }
    
    // MARK: Display
    
    func clear() {
        for buttonItemView in buttonItemViews {
            buttonItemView.removeFromSuperview()
        }
        buttonItemViews.removeAll()
    }
    
    func reloadButtonItemViews() {
        clear()
        
        guard let buttonItems = buttonItems else {
            return
        }
        
        for buttonItem in buttonItems {
            let buttonItemView = SRSButtonItemView()
            buttonItemView.applyStyles(styles)
            buttonItemView.buttonItem = buttonItem
            buttonItemView.onTap = { [weak self] in
                self?.onButtonItemTap?(buttonItem)
            }
            addSubview(buttonItemView)
            buttonItemViews.append(buttonItemView)
        }
        
        setNeedsLayout()
    }

    // MARK: Layout
    
    func getButtonFramesThatFit(_ size: CGSize) -> [CGRect] {
        var buttonFrames = [CGRect]()
        
        var contentTop: CGFloat = 0.0
        for buttonItemView in buttonItemViews {
            let buttonHeight = ceil(buttonItemView.sizeThatFits(CGSize(width: size.width, height: 0)).height)
            let buttonFrame = CGRect(x: 0, y: contentTop, width: size.width, height: buttonHeight)
            buttonFrames.append(buttonFrame)
            contentTop = buttonFrame.maxY
        }
        
        return buttonFrames
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frames = getButtonFramesThatFit(bounds.size)
        for (i, buttonItemView) in buttonItemViews.enumerated() {
            buttonItemView.frame = frames[i]
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let frames = getButtonFramesThatFit(bounds.size)
        var height: CGFloat = 0.0
        if let lastFrame = frames.last {
            height = lastFrame.maxY
        }
        
        return CGSize(width: size.width, height: height)
    }
}
