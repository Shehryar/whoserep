//
//  ImageViewerControlsView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ImageViewerControlsView: UIView {

    var onDismissButtonTap: (() -> Void)?
    
    private let dismissButton = UIButton()

    private let dismissButtonImageSize: CGFloat  = 22
    
    private let contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10)
    
    // MARK: Init
    
    func commonInit() {
        dismissButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        dismissButton.setImage(Images.xIcon(fillColor: UIColor.whiteColor(), alpha: 1), forState: .Normal)
        dismissButton.setImage(Images.xIcon(fillColor: UIColor.whiteColor(), alpha: 0.6), forState: .Highlighted)
        dismissButton.setImage(Images.xIcon(fillColor: UIColor.whiteColor(), alpha: 0.4), forState: .Disabled)
        dismissButton.addTarget(self, action: #selector(ImageViewerControlsView.didTapXButton), forControlEvents: .TouchUpInside)
        addSubview(dismissButton)
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
        
        let imageInsets = dismissButton.imageEdgeInsets
        let buttonWidth = dismissButtonImageSize + imageInsets.left + imageInsets.right
        let buttonHeight = dismissButtonImageSize + imageInsets.top + imageInsets.bottom
        let top = contentInset.top - imageInsets.top
        let left = CGRectGetWidth(bounds) - buttonWidth + imageInsets.right - contentInset.right
        dismissButton.frame = CGRect(x: left, y: top, width: buttonWidth, height: buttonHeight)
    }
    
    // MARK: Touches
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return CGRectContainsPoint(dismissButton.frame, point)
    }

    // MARK: Actions
    
    func didTapXButton() {
        onDismissButtonTap?()
    }
}
