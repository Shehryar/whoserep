//
//  SRSImageItemView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSImageItemView: UIView, ASAPPStyleable, StackableView {

    var imageItem: SRSImageItem? {
        didSet {
            if let imageItem = imageItem {
                imageView.sd_setImage(with: imageItem.imageURL)
            } else {
                imageView.image = nil
            }
        }
    }
    
    fileprivate let imageView = UIImageView()
    
    // MARK: Init
    
    func commonInit() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
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
    
    fileprivate(set) var styles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        
        backgroundColor = styles.backgroundColor1
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: floor(size.width * 0.4))
    }
    
    // MARK: StackableView
    
    func prefersFullWidthDisplay() -> Bool {
        return true
    }
}
