//
//  DemoCurrentSettingsBanner.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/11/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class DemoCurrentSettingsBanner: UIView {

    var foregroundColor: UIColor = UIColor.white {
        didSet {
            updateLabels()
        }
    }
    
    // MARK: Private Properties
    
    fileprivate let contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    
    fileprivate let versionLabel = UILabel()
    
    fileprivate let environmentLabel = UILabel()
    
    fileprivate let demoLabel = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = UIColor(red:0.243, green:0.243, blue:0.243, alpha:1)
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        versionLabel.text = "\(version) (\(build))"
        versionLabel.font = UIFont.systemFont(ofSize: 10)
        versionLabel.textColor = foregroundColor
        addSubview(versionLabel)
        
        environmentLabel.font = UIFont.boldSystemFont(ofSize: 10)
        addSubview(environmentLabel)
        
        demoLabel.font = UIFont.boldSystemFont(ofSize: 10)
        demoLabel.text = " - DEMO CONTENT"
        demoLabel.isHidden = true
        addSubview(demoLabel)
        
        updateLabels()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Layout Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let versionWidth = ceil(versionLabel.sizeThatFits(CGSize.zero).width)
        versionLabel.frame = CGRect(x: contentInset.left, y: 0.0, width: versionWidth, height: bounds.height)
        
        let environmentWidth = ceil(environmentLabel.sizeThatFits(CGSize.zero).width)
        let environmentLeft = versionLabel.frame.maxX + 10
        environmentLabel.frame = CGRect(x: environmentLeft, y: 0.0, width: environmentWidth, height: bounds.height)
        
        let demoWidth = ceil(demoLabel.sizeThatFits(CGSize.zero).width)
        let demoLeft = environmentLabel.frame.maxX
        demoLabel.frame = CGRect(x: demoLeft, y: 0, width: demoWidth, height: bounds.height)
    }
    
    // MARK: Actions
    
    func updateLabels() {
        versionLabel.textColor = foregroundColor
        
        let environment = DemoSettings.currentEnvironment()
        environmentLabel.text = DemoSettings.environmentString(environment: environment).uppercased()
        environmentLabel.textColor = foregroundColor
        
        demoLabel.textColor = foregroundColor
        demoLabel.isHidden = !DemoSettings.demoContentEnabled()
        
        // MITCH MITCH MITCH
        if COMCAST_LIVE_CHAT_DEMO {
            environmentLabel.text = "Live Chat Demo"
            if DemoSettings.useComcastPhoneUser() {
                demoLabel.text = " - +13126089137"
            } else {
                demoLabel.text = " - Default User"
            }
            demoLabel.isHidden = false
        }
        
        setNeedsLayout()
    }
}
