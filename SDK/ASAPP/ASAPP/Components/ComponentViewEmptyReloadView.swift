//
//  ComponentViewEmptyReloadView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/29/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentViewEmptyReloadView: UIView {

    var onButtonTap: (() -> Void)?
    
    let titleLabel = UILabel()
    
    let reloadButton = UIButton()
    
    let contentInset = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)

    // MARK: Initialization
    
    func commonInit() {
        titleLabel.text = ASAPP.strings.failureToLoadScreen
        titleLabel.textColor = ASAPP.styles.foregroundColor1
        titleLabel.font = ASAPP.styles.font(with: .bold, size: 15)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        addSubview(titleLabel)
        
        reloadButton.setTitle(ASAPP.strings.failureToLoadScreenReloadButton, for: .normal)
        reloadButton.setTitleColor(ASAPP.styles.textButtonColor, for: .normal)
        reloadButton.setTitleColor(ASAPP.styles.textButtonColorHighlighted, for: .highlighted)
        reloadButton.titleLabel?.font = ASAPP.styles.font(with: .black, size: 14)
        reloadButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        reloadButton.addTarget(self, action: #selector(ComponentViewEmptyReloadView.didTapButton), for: .touchUpInside)
        addSubview(reloadButton)
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
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        let left = contentInset.left
        let width = size.width - left - contentInset.right
        var top = contentInset.top
        let labelHeight = ceil(titleLabel.sizeThatFits(CGSize(width: width, height: 0)).height)
        let labelFrame = CGRect(x: left, y: top, width: width, height: labelHeight)
        
        top = labelFrame.maxY + 8
        let buttonHeight = ceil(reloadButton.sizeThatFits(CGSize(width: width, height: 0)).height)
        let buttonFrame = CGRect(x: left, y: top, width: width, height: buttonHeight)
        
        return (labelFrame, buttonFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
     
        let (labelFrame, buttonFrame) = getFramesThatFit(bounds.size)
        titleLabel.frame = labelFrame
        reloadButton.frame = buttonFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (_, buttonFrame) = getFramesThatFit(size)
        let width = buttonFrame.maxX + contentInset.right
        let height = buttonFrame.maxY + contentInset.bottom
        return CGSize(width: width, height: height)
    }
    
    // MARK:- Actions
    
    func didTapButton() {
        onButtonTap?()
    }
}
