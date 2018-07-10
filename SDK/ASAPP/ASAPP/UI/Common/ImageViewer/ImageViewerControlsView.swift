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

    private let dismissButtonImageSize: CGFloat = 18
    
    private let contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    
    // MARK: Init
    
    func commonInit() {
        dismissButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let icon = ComponentIcon.getImage(.navClose)
        dismissButton.setImage(icon?.tinted(UIColor.white, alpha: 1), for: UIControlState())
        dismissButton.setImage(icon?.tinted(UIColor.white, alpha: 0.6), for: .highlighted)
        dismissButton.setImage(icon?.tinted(UIColor.white, alpha: 0.4), for: .disabled)
        dismissButton.addTarget(self, action: #selector(ImageViewerControlsView.didTapXButton), for: .touchUpInside)
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
        let left = bounds.width - buttonWidth + imageInsets.right - contentInset.right
        dismissButton.frame = CGRect(x: left, y: top, width: buttonWidth, height: buttonHeight)
    }
    
    // MARK: Touches
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return dismissButton.frame.contains(point)
    }

    // MARK: Actions
    
    @objc func didTapXButton() {
        onDismissButtonTap?()
    }
}
