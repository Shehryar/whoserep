//
//  TableHeaderView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class TableHeaderView: UIView {
    
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 28, left: 30, bottom: 12, right: 30) {
        didSet {
            setNeedsLayout()
        }
    }

    var title: String? {
        didSet {
            updateLabel()
        }
    }
    
    fileprivate let label = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        label.font = DemoFonts.asapp.bold.withSize(13)
        label.textColor = UIColor.gray
        addSubview(label)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: App Settings
    
    fileprivate func updateLabel() {
        if let title = title {
            label.attributedText = NSAttributedString(string: title.uppercased(), attributes: [
                NSFontAttributeName: DemoFonts.asapp.bold.withSize(11),
                NSKernAttributeName: 1.5,
                NSForegroundColorAttributeName: AppSettings.shared.branding.colors.secondaryTextColor
            ])
        } else {
            label.attributedText = nil
        }
        setNeedsLayout()
    }
    
    // MARK: - Layout
    
    func labelFrameThatFits(_ size: CGSize) -> CGRect {
        let width = size.width - contentInset.left - contentInset.right
        let height = ceil(label.sizeThatFits(CGSize(width: width, height: 0)).height)
        
        return CGRect(x: contentInset.left, y: contentInset.top, width: width, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = labelFrameThatFits(bounds.size)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = labelFrameThatFits(size).maxY + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}
