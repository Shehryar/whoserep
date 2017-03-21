//
//  ProgressBarView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ProgressBarView: UIView, ComponentView {
    
    let progressBarContainer = UIView()
    
    let progressBar = UIView()
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            
            let style = progressBarItem?.style
            progressBar.backgroundColor = style?.color ?? ProgressBarItem.defaultColor
            progressBarContainer.backgroundColor = style?.backgroundColor ?? ProgressBarItem.defaultBackgroundColor
            backgroundColor = UIColor.clear
        }
    }
    
    var progressBarItem: ProgressBarItem? {
        return component as? ProgressBarItem
    }
    
    // MARK: Init
    
    func commonInit() {
        progressBarContainer.clipsToBounds = true
        addSubview(progressBarContainer)
        
        
        progressBarContainer.addSubview(progressBar)
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
        
        let padding = progressBarItem?.style.padding ?? UIEdgeInsets.zero
        progressBarContainer.frame = UIEdgeInsetsInsetRect(bounds, padding)
        let barHeight = progressBarContainer.bounds.height
        
        let fillPercentage = progressBarItem?.fillPercentage ?? 0.0
        let barWidth = floor(progressBarContainer.bounds.width * fillPercentage)
        progressBar.frame = CGRect(x: 0, y: 0, width: barWidth, height: barHeight)
        
        progressBarContainer.layer.cornerRadius = barHeight / 2.0
        progressBar.layer.cornerRadius = barHeight / 2.0
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let progressBarItem = progressBarItem else {
            return .zero
        }
        
        let style = progressBarItem.style
        let padding = style.padding
        let height = (style.height > 0 ? style.height : ProgressBarItem.defaultHeight)
            + padding.top + padding.bottom
        
        return CGSize(width: size.width, height: height)
    }

}
