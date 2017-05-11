//
//  TabViewTab.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/10/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TabViewTab: UIView {

    var isSelected: Bool = false {
        didSet {
            updateDisplay()
        }
    }
    
    var title: String? {
        didSet {
            updateDisplay()
            setNeedsLayout()
        }
    }
    
    var padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12) {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: Private Properties
    
    fileprivate let label = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        addSubview(label)
        
        updateDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Display
    
    func updateDisplay() {
        let tabColor: UIColor
        let titleColor: UIColor
        if isSelected {
            tabColor = ASAPP.styles.colors.backgroundPrimary
            titleColor = ASAPP.styles.colors.textPrimary
        } else {
            tabColor = ASAPP.styles.colors.backgroundSecondary
            titleColor = ASAPP.styles.colors.textSecondary
        }
        
        backgroundColor = tabColor
        label.setAttributedText(title,
                                textType: .subheader,
                                color: titleColor)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let maxLabelSize = CGSize(width: max(0, size.width - padding.left - padding.right),
                                  height: max(0, size.height - padding.top - padding.bottom))
        let labelSize = label.sizeThatFits(maxLabelSize)
        guard labelSize.width > 0 && labelSize.height > 0 else {
            return .zero
        }
        
        let fittedSize = CGSize(width: ceil(labelSize.width + padding.left + padding.right),
                                height: ceil(labelSize.height + padding.top + padding.bottom))
        
        return fittedSize
    }
}
