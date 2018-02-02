//
//  RestartActionButtonCell.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 1/29/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation
import UIKit

class RestartActionButtonCell: QuickReplyCell {
    override class var reuseIdentifier: String {
        return "RestartActionButtonCell"
    }
    
    override func commonInit() {
        super.commonInit()
        
        update(for: nil, enabled: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        button.layer.cornerRadius = button.frame.height / 2
        shadowView.layer.cornerRadius = button.layer.cornerRadius
    }
    
    func showSpinner() {
        button.isEnabled = false
        button.titleLabel?.removeFromSuperview()
        
        let spinner = UIActivityIndicatorView(frame: button.bounds)
        spinner.activityIndicatorViewStyle = .gray
        button.addSubview(spinner)
        spinner.startAnimating()
        
        button.setNeedsLayout()
        button.layoutIfNeeded()
    }
}
