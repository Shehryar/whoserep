//
//  ModalCardContentView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ModalCardContentView: UIView {

    let contentInset = UIEdgeInsets(top: 26, left: 28, bottom: 32, right: 28)
    let titleMarginBottom: CGFloat = 26.5
    
    let titleView = ModalCardTitleView()
    
    // MARK: Initialization
    
    func commonInit() {
        clipsToBounds = false
        
        addSubview(titleView)
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
        
        updateFrames()
    }
    
    func updateFrames() {
        titleView.frame = getTitleViewFrameThatFits(bounds.size)
    }
}

// MARK: - Layout

extension ModalCardContentView {
    
    func getTitleViewFrameThatFits(_ size: CGSize) -> CGRect {
        let contentWidth = size.width - contentInset.left - contentInset.right
        let titleViewHeight = ceil(titleView.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        return CGRect(x: contentInset.left, y: contentInset.top, width: contentWidth, height: titleViewHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let titleViewFrame = getTitleViewFrameThatFits(size)
        return CGSize(width: size.width, height: titleViewFrame.maxY + contentInset.bottom)
    }
}
