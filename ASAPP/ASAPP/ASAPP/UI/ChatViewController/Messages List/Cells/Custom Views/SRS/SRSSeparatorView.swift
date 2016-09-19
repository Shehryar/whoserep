//
//  SRSSeparatorView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSSeparatorView: UIView, ASAPPStyleable {

    var separatorStroke: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private let separatorView = HorizontalGradientView()
    
    // MARK: Initialization
    
    func commonInit() {
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

    // MARK: ASAPPStyleable
    
    private(set) var styles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        let color = styles.separatorColor1
        separatorView.update(color.colorWithAlphaComponent(0),
                             middleColor: color,
                             rightColor: color.colorWithAlphaComponent(0))
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        separatorView.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(bounds), height: separatorStroke)
    }

    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: separatorStroke)
    }
    
}
