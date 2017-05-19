//
//  ComponentViewEmptyReloadView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/29/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentViewEmptyReloadView: UIView {

    var onReloadButtonTap: (() -> Void)?
    
    var onCloseButtonTap: (() -> Void)?
    
    let titleLabel = UILabel()
    
    let reloadButton = UIButton()
    
    let closeButton = UIButton()
    
    let contentInset = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)

    // MARK: Initialization
    
    func commonInit() {
        titleLabel.setAttributedText(ASAPP.strings.failureToLoadScreen,
                                     textType: .header2)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        addSubview(titleLabel)
        
        reloadButton.updateText(ASAPP.strings.failureToLoadScreenReloadButton, buttonType: .textPrimary)
        reloadButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        reloadButton.addTarget(self, action: #selector(ComponentViewEmptyReloadView.didTapReloadButton), for: .touchUpInside)
        addSubview(reloadButton)
        
        closeButton.updateText(ASAPP.strings.failureToLoadScreenCloseButton, buttonType: .textSecondary)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        closeButton.addTarget(self, action: #selector(ComponentViewEmptyReloadView.didTapCloseButton), for: .touchUpInside)
        addSubview(closeButton)

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK:- Layout
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect, CGRect) {
        let left = contentInset.left
        let width = size.width - left - contentInset.right
        var top = contentInset.top
        let labelHeight = ceil(titleLabel.sizeThatFits(CGSize(width: width, height: 0)).height)
        let labelFrame = CGRect(x: left, y: top, width: width, height: labelHeight)
        
        top = labelFrame.maxY + 36
        let reloadButtonHeight = ceil(reloadButton.sizeThatFits(CGSize(width: width, height: 0)).height)
        let reloadButtonFrame = CGRect(x: left, y: top, width: width, height: reloadButtonHeight)
        
        top = reloadButtonFrame.maxY + 4
        let closeButtonHeight = ceil(closeButton.sizeThatFits(CGSize(width: width, height: 0)).height)
        let closeButtonFrame = CGRect(x: left, y: top, width: width, height: closeButtonHeight)
        
        return (labelFrame, reloadButtonFrame, closeButtonFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
     
        let (labelFrame, reloadButtonFrame, closeButtonFrame) = getFramesThatFit(bounds.size)
        titleLabel.frame = labelFrame
        reloadButton.frame = reloadButtonFrame
        closeButton.frame = closeButtonFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (_, _, buttonFrame) = getFramesThatFit(size)
        let width = buttonFrame.maxX + contentInset.right
        let height = buttonFrame.maxY + contentInset.bottom
        return CGSize(width: width, height: height)
    }
    
    // MARK:- Actions
    
    func didTapReloadButton() {
        onReloadButtonTap?()
    }
    
    func didTapCloseButton() {
        onCloseButtonTap?()
    }
}
