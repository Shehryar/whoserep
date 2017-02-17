//
//  SRSSeparatorView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSSeparatorView: UIView {

    var separatorStroke: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    fileprivate let separatorView = HorizontalGradientView()
    
    // MARK: Initialization
    
    func commonInit() {
        let color = ASAPP.styles.separatorColor1
        separatorView.update(color.withAlphaComponent(0),
                             middleColor: color,
                             rightColor: color.withAlphaComponent(0))
        addSubview(separatorView)
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
        
        separatorView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: separatorStroke)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: separatorStroke)
    }
    
}
