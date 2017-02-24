//
//  SRSFillerView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSFillerView: UIView {

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
    
    fileprivate let fillerView = UIView()
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = ASAPP.styles.backgroundColor2
        fillerView.backgroundColor = ASAPP.styles.foregroundColor2
        addSubview(fillerView)
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
        
        let top = floor((bounds.height - fillerSize.height) / 2.0)
        let left = floor((bounds.width - fillerSize.width) / 2.0)
        fillerView.frame = CGRect(x: left, y: top, width: fillerSize.width, height: fillerSize.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: fillerSize.width + contentInset.left + contentInset.right,
                      height: fillerSize.height + contentInset.top + contentInset.bottom)
    }
}
