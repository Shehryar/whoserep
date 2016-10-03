//
//  DebugStageProdToggleView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 9/30/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class DebugStageProdToggleView: UIView {

    var onEnvironmentChange: ((_ isUsingProduction: Bool) -> Void)?
    
    let toggle = UISwitch()
    let stageLabel = UILabel()
    let prodLabel = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        toggle.isOn = DebugStageProdToggleView.debuggingWithProduction()
        toggle.addTarget(self, action: #selector(DebugStageProdToggleView.toggleDidChange), for: .valueChanged)
        addSubview(toggle)
        
        stageLabel.text = "STAGING"
        stageLabel.textColor = UIColor.white
        stageLabel.font = UIFont(name: "Avenir-Medium", size: 14)
        addSubview(stageLabel)
        
        prodLabel.text = "PRODUCTION"
        prodLabel.textColor = UIColor.white
        prodLabel.font = UIFont(name: "Avenir-Medium", size: 14)
        addSubview(prodLabel)
        
        updateAlphas(animated: false)
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
        
        toggle.sizeToFit()
        toggle.center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let labelMargin: CGFloat = 15.0
        let stageWidth = ceil(stageLabel.sizeThatFits(CGSize.zero).width)
        let stageLeft = toggle.frame.minX - stageWidth - labelMargin
        stageLabel.frame = CGRect(x: stageLeft, y: 0, width: stageWidth, height: bounds.height)
        
        let prodWidth = ceil(prodLabel.sizeThatFits(CGSize.zero).width)
        let prodLeft = toggle.frame.maxX + labelMargin
        prodLabel.frame = CGRect(x: prodLeft, y: 0, width: prodWidth, height: bounds.height)
    }
    
    // MARK: Updates
    
    func updateAlphas(animated: Bool) {
        func update() {
            if toggle.isOn {
                stageLabel.alpha = 0.5
                prodLabel.alpha = 1.0
            } else {
                stageLabel.alpha = 1.0
                prodLabel.alpha = 0.5
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: update)
        } else {
            update()
        }
    }
    
    func toggleDidChange() {
        DebugStageProdToggleView.setDebuggingWithProduction(useProduction: toggle.isOn)
        
        updateAlphas(animated: true)
        
        onEnvironmentChange?(DebugStageProdToggleView.debuggingWithProduction())
    }

    // MARK:- Saving
    
    static let DEBUG_WITH_PROD_KEY = "ASAPP_DEBUGGING_WITH_PROD"
    
    class func debuggingWithProduction() -> Bool {
        return UserDefaults.standard.bool(forKey: DEBUG_WITH_PROD_KEY)
    }
    
    class func setDebuggingWithProduction(useProduction: Bool) {
        UserDefaults.standard.set(useProduction, forKey: DEBUG_WITH_PROD_KEY)
    }
}

