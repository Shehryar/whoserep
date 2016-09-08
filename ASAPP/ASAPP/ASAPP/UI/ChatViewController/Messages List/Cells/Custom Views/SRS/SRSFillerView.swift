//
//  SRSFillerView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSFillerView: UIView, ASAPPStyleable {

    var contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var fillerSize = CGSize(width: 15, height: 4) {
        didSet {
            setNeedsLayout()
        }
    }
    
    let fillerView = UIView()
    
    // MARK: Initialization
    
    func commonInit() {
        addSubview(fillerView)
        applyStyles(styles)
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
        
        fillerView.backgroundColor = styles.foregroundColor2
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let top = floor((CGRectGetHeight(bounds) - fillerSize.height) / 2.0)
        let left = floor((CGRectGetWidth(bounds) - fillerSize.width) / 2.0)
        fillerView.frame = CGRect(x: left, y: top, width: fillerSize.width, height: fillerSize.height)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: fillerSize.width + contentInset.left + contentInset.right,
                      height: fillerSize.height + contentInset.top + contentInset.bottom)
    }
}
