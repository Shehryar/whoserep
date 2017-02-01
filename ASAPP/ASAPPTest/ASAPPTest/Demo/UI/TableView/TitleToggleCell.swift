//
//  TitleToggleCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class TitleToggleCell: TableViewCell {

    var title: String? {
        didSet {
            titleLabel.text = title
            setNeedsLayout()
        }
    }
    
    var isOn: Bool = false {
        didSet {
            toggle.isOn = isOn
        }
    }
    
    var onToggleChange: ((_ isOn: Bool) -> Void)?
    
    var toggleMargin: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override class var reuseId: String {
        return "TitleToggleCellReuseId"
    }
    
    // MARK: Subviews
    
    let titleLabel = AttributedLabel()
    
    let toggle = UISwitch()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        selectionStyle = .none
        contentInset = UIEdgeInsets(top: 12, left: contentInset.left, bottom: 12, right: contentInset.right)
        
        titleLabel.font = DemoFonts.latoRegularFont(withSize: 16)
        titleLabel.kerning = 1
        titleLabel.textColor = UIColor.darkText
        contentView.addSubview(titleLabel)
        
        toggle.addTarget(self, action: #selector(TitleToggleCell.toggleDidChange), for: .valueChanged)
        contentView.addSubview(toggle)
    }
    
    // MARK: Styling
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        if let appSettings = appSettings {
            titleLabel.font = appSettings.branding.fonts.regularFont.withSize(16)
            titleLabel.textColor = appSettings.branding.colors.foregroundColor
            
            toggle.onTintColor = appSettings.branding.colors.accentColor
        }
        
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    func framesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        
        var toggleSize = toggle.sizeThatFits(CGSize(width: size.width, height: 0))
        toggleSize.width = ceil(toggleSize.width)
        toggleSize.height = ceil(toggleSize.height)

        let toggleLeft = size.width - contentInset.right - toggleSize.width
        
        let labelWidth = toggleLeft - toggleMargin - contentInset.left
        let labelHeight = ceil(titleLabel.sizeThatFits(CGSize(width: labelWidth, height: 0)).height)
        let labelTop = contentInset.top + max(0, floor((toggleSize.height - labelHeight) / 2.0))
        let toggleTop = contentInset.top + max(0, floor((labelHeight - toggleSize.height) / 2.0))
        
        let labelFrame = CGRect(x: contentInset.left, y: labelTop, width: labelWidth, height: labelHeight)
        let toggleFrame = CGRect(x: toggleLeft, y: toggleTop, width: toggleSize.width, height: toggleSize.height)
        
        return (labelFrame, toggleFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (labelFrame, toggleFrame) = framesThatFit(bounds.size)
        titleLabel.frame = labelFrame
        toggle.frame = toggleFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (labelFrame, toggleFrame) = framesThatFit(size)
        let height = max(labelFrame.maxY, toggleFrame.maxY) + contentInset.bottom
  
        return CGSize(width: size.width, height: height)
    }
    
    // MARK: Actions
    
    func toggleDidChange() {
        onToggleChange?(toggle.isOn)
    }
}
