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
            applyAppSettings()
        }
    }
    
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30) {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var selectionStyle: UITableViewCell.SelectionStyle {
        didSet {
            updateSelectedView()
        }
    }
    
    fileprivate let selectedView = UIView()

    class var reuseId: String {
        fatalError("Subclass must override +reuseId")
    }
    
    // MARK: Init
    
    func commonInit() {
        separatorInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    // MARK: View
    
    func applyAppSettings() {
        if let appSettings = appSettings {
            backgroundColor = appSettings.branding.colors.backgroundColor
        }
        updateSelectedView()
    }
    
    func updateSelectedView() {
        if selectionStyle == .none {
            selectedView.backgroundColor = UIColor.clear
            selectedBackgroundView = selectedView
        } else {
            if let appSettings = appSettings {
                selectedView.backgroundColor = appSettings.branding.colors.backgroundColor.highlightColor()
                selectedBackgroundView = selectedView
            } else {
                selectedBackgroundView = nil
            }
        }
    }
}
