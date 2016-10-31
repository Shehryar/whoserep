//
//  DemoSettingsTableViewCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/11/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class DemoSettingsTableViewCell: UITableViewCell {

    var title: String? {
        didSet {
            textLabel?.text = title
            setNeedsLayout()
        }
    }
    
    var isOn: Bool = false {
        didSet {
            toggle.isOn = isOn
        }
    }
    
    var onToggleChange: ((_ isOn: Bool) -> Void)?
    
    var contentInset = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var toggleMargin: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: Private Properties
    
    fileprivate let toggle = UISwitch()
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .none
        
        textLabel?.numberOfLines = 0
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        textLabel?.textAlignment = .left
        
        toggle.addTarget(self, action: #selector(DemoSettingsTableViewCell.toggleDidChange), for: .valueChanged)
        contentView.addSubview(toggle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    // MARK: Layout
    
    func labelSizeThatFits(_ size: CGSize) -> CGSize {
        guard let textLabel = textLabel else { return CGSize.zero }
        
        let maxWidth = size.width - contentInset.left - contentInset.right - getToggleSize().width - toggleMargin
        let textHeight = ceil(textLabel.sizeThatFits(CGSize(width: maxWidth, height: 0)).height)
        return CGSize(width: maxWidth, height: textHeight)
    }
    
    func getToggleSize() -> CGSize {
        var size = toggle.sizeThatFits(CGSize.zero)
        size.width = ceil(size.width)
        size.height = ceil(size.height)
        return size
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelSize = labelSizeThatFits(bounds.size)
        let labelTop = floor((bounds.height - labelSize.height) / 2.0)
        textLabel?.frame = CGRect(x: contentInset.left, y: labelTop, width: labelSize.width, height: labelSize.height)
        
        let toggleSize = getToggleSize()
        let toggleLeft = bounds.width - contentInset.right - toggleSize.width
        let toggleTop = floor((bounds.height - toggleSize.height) / 2.0)
        toggle.frame = CGRect(x: toggleLeft, y: toggleTop, width: toggleSize.width, height: toggleSize.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelSize = labelSizeThatFits(size)
        let toggleSize = getToggleSize()
        let contentHeight = max(labelSize.height, toggleSize.height)
        return CGSize(width: size.width, height: contentHeight + contentInset.top + contentInset.bottom)
    }
    
    // MARK: Actions
    
    func toggleDidChange() {
        onToggleChange?(toggle.isOn)
    }
}
