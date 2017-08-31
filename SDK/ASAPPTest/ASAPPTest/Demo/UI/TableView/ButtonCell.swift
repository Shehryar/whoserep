//
//  ButtonCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ButtonCell: TableViewCell {

    enum Alignment {
        case left
        case center
        case right
    }
    
    var title: String? {
        didSet {
            updateLabel()
        }
    }
    
    var titleAlignment: Alignment = .center {
        didSet {
            switch titleAlignment {
            case .left:
                titleLabel.textAlignment = .left
                break
                
            case .center:
                titleLabel.textAlignment = .center
                break
                
            case .right:
                titleLabel.textAlignment = .right
                break
            }
            
            setNeedsLayout()
        }
    }
    
    var loading: Bool = false {
        didSet {
            guard loading != oldValue else {
                return
            }
            
            if loading {
                spinner.startAnimating()
                titleLabel.alpha = 0.25
                selectionStyle = .none
            } else {
                spinner.stopAnimating()
                titleLabel.alpha = 1
                selectionStyle = .default
            }
            applyAppSettings()
        }
    }
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    let titleLabel = AttributedLabel()
    
    override class var reuseId: String {
        return "ButtonCellReuseId"
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        contentInset = UIEdgeInsets(top: 16, left: contentInset.left,
                                    bottom: 16, right: contentInset.right)
        
        updateLabel()
        contentView.addSubview(titleLabel)
        
        spinner.hidesWhenStopped = true
        contentView.addSubview(spinner)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        
        if loading {
            spinner.startAnimating()
        }
    }
    
    // MARK: Updates
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        updateLabel()
    }
    
    func updateLabel() {
        titleLabel.update(text: title,
                          textColor: AppSettings.shared.branding.colors.accentColor,
                          font: AppSettings.shared.branding.fonts.mediumFont.withSize(14),
                          kerning: 1)
    }
    
    // MARK: Layout
    
    func labelFrameThatFits(_ size: CGSize) -> CGRect {
        let width = size.width - contentInset.left - contentInset.right
        var labelSize = titleLabel.sizeThatFits(CGSize(width: width, height: 0))
        labelSize.height = ceil(labelSize.height)
        labelSize.width = ceil(labelSize.width)
        
        let left: CGFloat
        switch titleAlignment {
        case .left:
            left = contentInset.left
            break
            
        case .center:
            left = floor((size.width - labelSize.width) / 2.0)
            break
            
        case .right:
            left = size.width - contentInset.right - labelSize.width
            break
        }
        let labelFrame = CGRect(x: left, y: contentInset.top,
                                width: labelSize.width,
                                height: labelSize.height)
        
        return labelFrame
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = labelFrameThatFits(bounds.size)
        
        spinner.sizeToFit()
        spinner.center = titleLabel.center
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = labelFrameThatFits(size).maxY + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}
