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
    override var textInset: UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 36, bottom: 10, right: 36)
    }
    
    var activityIndicatorStyle: UIActivityIndicatorViewStyle = .white
    
    private var activityIndicator: UIActivityIndicatorView?
    
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
        button.titleLabel?.alpha = 0
        
        activityIndicator = UIActivityIndicatorView(frame: button.bounds)
        if let spinner = activityIndicator {
            spinner.activityIndicatorViewStyle = activityIndicatorStyle
            button.addSubview(spinner)
            spinner.startAnimating()
        }
        
        button.setNeedsLayout()
        button.layoutIfNeeded()
    }
    
    func hideSpinner() {
        activityIndicator?.removeFromSuperview()
        button.isEnabled = true
        button.titleLabel?.alpha = 1
        button.setNeedsLayout()
        button.layoutIfNeeded()
    }
}
