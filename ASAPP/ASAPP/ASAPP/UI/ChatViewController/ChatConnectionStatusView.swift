//
//  ChatConnectionStatusView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatConnectionStatusView: UIView, ASAPPStyleable {

    var message: String? {
        didSet {
            label.text = message
        }
    }
    
    var loading: Bool = false {
        didSet {
            if loading {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
         }
    }
    
    // MARK: Private Properties
    
    private let label = UILabel()
    
    private let spinner = UIActivityIndicatorView()
    
    private let contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
    // MARK: Init
    
    func commonInit() {
        applyStyles(styles)
        
        addSubview(label)
        addSubview(spinner)
        
        updateConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: ASAPPStyleable
    
    private(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        backgroundColor = styles.backgroundColor2
        if styles.backgroundColor2.isDark() {
            spinner.activityIndicatorViewStyle = .White
        } else {
            spinner.activityIndicatorViewStyle = .Gray
        }
        
        label.textColor = styles.foregroundColor1
        label.font = styles.detailFont
        label.textAlignment = .Center
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        spinner.sizeToFit()
        spinner.center = CGPoint(x: CGRectGetWidth(bounds) - contentInset.right - CGRectGetWidth(spinner.bounds) / 2.0,
                                 y: CGRectGetMidY(bounds))
        
        let horizontalInset = CGRectGetWidth(bounds) - CGRectGetMinX(spinner.frame) - 8.0
        let labelWidth = CGRectGetWidth(bounds) - 2 * horizontalInset
        label.frame = CGRect(x: horizontalInset, y: 0, width: labelWidth, height: CGRectGetHeight(bounds))
    }
}
