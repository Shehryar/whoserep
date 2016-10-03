//
//  DebugInfoSettingsView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 9/30/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class DebugInfoSettingsView: UIView {
    
    var onCustomChatTap: (() -> Void)?
    
    var onEnvironmentChange: ((_ isUsingProduction: Bool) -> Void)? {
        didSet {
            toggleView.onEnvironmentChange = onEnvironmentChange
        }
    }
    
    var onDoneTap: (() -> Void)?
    
    // MARK: Subviews
    
    let chatButton = UIButton()
    
    let versionLabel = UILabel()
    
    let doneButton = UIButton()
    
    let toggleView = DebugStageProdToggleView()
    
    let contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    // MARK: Initialization
    
    func commonInit() {

        versionLabel.textColor = UIColor.white
        versionLabel.font = UIFont(name: "Avenir-Book", size: 14)
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        versionLabel.text = "\(version) (\(build))"
        addSubview(versionLabel)
        
        let buttonColor = UIColor(red:0.298, green:0.851, blue:0.391, alpha:1)
        
        doneButton.setAttributedTitle(NSAttributedString(string: "DONE", attributes: [
            NSFontAttributeName : UIFont(name: "Avenir-Black", size: 12) ?? UIFont.boldSystemFont(ofSize: 12),
            NSForegroundColorAttributeName : buttonColor,
            NSKernAttributeName : 1.3
            ]), for: .normal)
        doneButton.setAttributedTitle(NSAttributedString(string: "DONE", attributes: [
            NSFontAttributeName : UIFont(name: "Avenir-Black", size: 12) ?? UIFont.boldSystemFont(ofSize: 12),
            NSForegroundColorAttributeName : buttonColor.withAlphaComponent(0.5),
            NSKernAttributeName : 1.3
            ]), for: .highlighted)
        doneButton.addTarget(self, action: #selector(DebugInfoSettingsView.didTapDoneButton), for: .touchUpInside)
        
        addSubview(doneButton)
        
        addSubview(toggleView)
        
        
        chatButton.setAttributedTitle(NSAttributedString(string: "SHOW CHAT", attributes: [
            NSFontAttributeName : UIFont(name: "Avenir-Black", size: 14) ?? UIFont.boldSystemFont(ofSize: 14),
            NSForegroundColorAttributeName : buttonColor,
            NSKernAttributeName : 1.3
            ]), for: .normal)
        chatButton.setAttributedTitle(NSAttributedString(string: "SHOW CHAT", attributes: [
            NSFontAttributeName : UIFont(name: "Avenir-Black", size: 14) ?? UIFont.boldSystemFont(ofSize: 14),
            NSForegroundColorAttributeName : buttonColor.withAlphaComponent(0.5),
            NSKernAttributeName : 1.3
            ]), for: .highlighted)
        chatButton.addTarget(self, action: #selector(DebugInfoSettingsView.didTapChatButton), for: .touchUpInside)
        addSubview(chatButton)
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
        
        let doneButtonHeight: CGFloat = 45
        let doneButtonWidth = max(60, ceil(doneButton.sizeThatFits(CGSize.zero).width) + 30)
        let doneButtonLeft = bounds.width - doneButtonWidth
        doneButton.frame = CGRect(x: doneButtonLeft, y: 10, width: doneButtonWidth, height: doneButtonHeight)
        
        let versionLabelWidth = ceil(versionLabel.sizeThatFits(CGSize.zero).width)
        versionLabel.frame = CGRect(x: 15.0, y: 10, width: versionLabelWidth, height: 45)
        
        let contentWidth = bounds.width - contentInset.left - contentInset.right
        
        let toggleTop = doneButton.frame.maxY + 10
        let toggleHeight: CGFloat = 50
        toggleView.frame = CGRect(x: contentInset.left, y: toggleTop, width: contentWidth, height: toggleHeight)
        
        let buttonHeight: CGFloat = 45
        let chatButtonTop = bounds.height - contentInset.bottom - buttonHeight
        chatButton.frame = CGRect(x: contentInset.left, y: chatButtonTop, width: contentWidth, height: buttonHeight)
    }
    
    // MARK: Actions
    
    func didTapChatButton() {
        onCustomChatTap?()
    }
    
    func didTapDoneButton() {
        onDoneTap?()
    }
}
