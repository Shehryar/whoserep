//
//  DebugInfoView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 9/30/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class DebugInfoView: UIView {

    var onCustomChatTap: (() -> Void)? {
        didSet {
            settingsView.onCustomChatTap = onCustomChatTap
        }
    }
    
    var onEnvironmentChange: ((_ isUsingProduction: Bool) -> Void)?
    
    var isUsingProduction: Bool {
        return DebugStageProdToggleView.debuggingWithProduction()
    }
    
    // MARK: Subviews
    
    let scrollView = UIScrollView()
    
    let settingsView = DebugInfoSettingsView()
    
    let openButtonContainer = UIView()
    
    let openButton = UIButton()
    
    // MARK: Initialization
    
    func commonInit() {
        scrollView.clipsToBounds = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.scrollsToTop = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        settingsView.backgroundColor = UIColor(red:0.039, green:0.039, blue:0.039, alpha:1)
        settingsView.onDoneTap = {
            self.setSettingsViewHidden(hidden: true, animated: true)
        }
        settingsView.onEnvironmentChange = { (usingProduction) in
            self.updateOpenButton()
            
            self.onEnvironmentChange?(usingProduction)
        }
        
        openButtonContainer.backgroundColor = UIColor(red:0.039, green:0.039, blue:0.039, alpha:1)
        scrollView.addSubview(openButtonContainer)
        
        openButton.titleLabel?.numberOfLines = 0
        openButton.titleLabel?.lineBreakMode = .byWordWrapping
        openButton.titleLabel?.textAlignment = .center
        openButton.addTarget(self, action: #selector(DebugInfoView.didTapOpen), for: .touchUpInside)
        updateOpenButton()
        openButtonContainer.addSubview(openButton)
        
        scrollView.addSubview(settingsView)
        
        func applyShadow(shadowView: UIView) {
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOpacity = 0.5
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
            shadowView.layer.shadowRadius = 3
        }
        applyShadow(shadowView: openButtonContainer)
        applyShadow(shadowView: settingsView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Updates
    
    func updateOpenButton() {
        let titleText = DebugStageProdToggleView.debuggingWithProduction() ? "PRODUCTION" : "STAGING"
        
        openButton.setAttributedTitle(NSAttributedString(string: titleText, attributes: [
            NSFontAttributeName : UIFont(name: "Avenir-Black", size: 12) ?? UIFont.boldSystemFont(ofSize: 12),
            NSForegroundColorAttributeName : UIColor.white,
            NSKernAttributeName : 1.3
            ]), for: .normal)
        openButton.setAttributedTitle(NSAttributedString(string: titleText, attributes: [
            NSFontAttributeName : UIFont(name: "Avenir-Black", size: 12) ?? UIFont.boldSystemFont(ofSize: 12),
            NSForegroundColorAttributeName : UIColor.white.withAlphaComponent(0.5),
            NSKernAttributeName : 1.3
            ]), for: .highlighted)

        setNeedsLayout()
    }
    
    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        scrollView.contentSize = CGSize(width: 2 * bounds.width, height: bounds.height)
        
        settingsView.frame = CGRect(x: bounds.width, y: 0, width: bounds.width, height: bounds.height)
        
        var buttonSize = openButton.sizeThatFits(CGSize.zero)
        buttonSize.width = ceil(buttonSize.width)
        buttonSize.height = ceil(buttonSize.height)
        let buttonInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        let buttonContainerSize = CGSize(width: buttonSize.width + buttonInset.left + buttonInset.right, height: buttonSize.height + buttonInset.top + buttonInset.bottom)
        let buttonContainerTop: CGFloat = bounds.height - buttonContainerSize.height - 10
        let buttonContainerLeft = bounds.width - buttonContainerSize.width //- 20
        openButtonContainer.frame = CGRect(x: buttonContainerLeft, y: buttonContainerTop, width: buttonContainerSize.width, height: buttonContainerSize.height)
        
        openButton.frame = openButtonContainer.bounds
    }
    
    // MARK: Actions
    
    func didTapOpen() {
        setSettingsViewHidden(hidden: false, animated: true)
    }
    
    func setSettingsViewHidden(hidden: Bool, animated: Bool) {
        let offset = hidden ? 0 : bounds.width
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
}
