//
//  SRSLoaderBarView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/12/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSLoaderBarView: UIView, ASAPPStyleable {
    
    private let loaderView = UIImageView()
    
    private let loaderHeight: CGFloat = 20.0
    
    private let contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
    // MARK: Initialization
    
    func commonInit() {
        loaderView.backgroundColor = UIColor.redColor()
        loaderView.image = Images.gifLoaderBar()
        loaderView.contentMode = .ScaleToFill
        addSubview(loaderView)
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
        
        
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let top = floor((CGRectGetHeight(bounds) - loaderHeight) / 2.0)
        let left = contentInset.left
        let width = CGRectGetWidth(bounds) - contentInset.left - contentInset.right
        loaderView.frame = CGRect(x: left, y: top, width: width, height: loaderHeight)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: loaderHeight + contentInset.top + contentInset.bottom)
    }
}
