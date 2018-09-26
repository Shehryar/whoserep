//
//  SecureScreenCoverView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/15/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SecureScreenCoverView: UIView {

    let label = UILabel()
    
    let contentInset = UIEdgeInsets(top: 32, left: 24, bottom: 32, right: 24)
    
    // MARK: Initialization
    
    func commonInit() {
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setAttributedText(ASAPP.strings.secureScreenCoverText,
                                textType: .detail2)
        addSubview(label)
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
        
        let maxLabelFrame = UIEdgeInsetsInsetRect(bounds, contentInset)
        let labelHeight = ceil(label.sizeThatFits(maxLabelFrame.size).height)
        let labelTop = bounds.height - contentInset.bottom - labelHeight
        
        label.frame = CGRect(x: contentInset.left, y: labelTop,
                             width: bounds.width - contentInset.horizontal, height: labelHeight)
    }
}
