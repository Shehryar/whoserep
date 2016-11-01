//
//  TableViewCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    var appSettings: AppSettings? {
        didSet {
            if appSettings != oldValue {
                applyAppSettings()
            }
        }
    }
    
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30) {
        didSet {
            setNeedsLayout()
        }
    }
    
    fileprivate let selectedView = UIView()
    
    // MARK: Init
    
    func commonInit() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    // MARK: View
    
    func applyAppSettings() {
        if let appSettings = appSettings {
            backgroundColor = appSettings.backgroundColor
            
            selectedView.backgroundColor = appSettings.backgroundColor.highlightColor()
            selectedBackgroundView = selectedView
        }
    }
}
