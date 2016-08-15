//
//  ChatConnectionStatusView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatConnectionStatusView: UIView, ASAPPStyleable {

    enum ChatConnectionStatus {
        case Connected
        case Connecting
        case Disconnected
    }
    
    var message: String? {
        didSet {
            label.text = message
        }
    }
    
    var status: ChatConnectionStatus = .Disconnected {
        didSet {
            switch status {
            case .Connected:
                spinner.stopAnimating()
                // TODO: Localization
                message = "Connection Established"
                break
                
            case .Connecting:
                spinner.startAnimating()
                // TODO: Localization
                message = "Connecting..."
                break
                
                
            case .Disconnected:
                spinner.stopAnimating()
                // TODO: Localization
                message = "Not connected. Retry connection?"
                break
            }
            
            updateColors()
        }
    }
    
    var onTapToConnect: (() -> Void)?
    
    // MARK: Private Properties
    
    private let label = UILabel()
    
    private let spinner = UIActivityIndicatorView()
    
    private let contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
    // MARK: Init
    
    func commonInit() {
        applyStyles(styles)
        
        addSubview(label)
        addSubview(spinner)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChatConnectionStatusView.didTap)))
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
    
        label.font = styles.detailFont
        label.textAlignment = .Center
        
        updateColors()
    }
    
    func updateColors() {
        switch status {
        case .Connected:
            backgroundColor = styles.backgroundColor2
            label.textColor = styles.foregroundColor2
            break
            
        case .Connecting:
            backgroundColor = styles.backgroundColor2
            label.textColor = styles.foregroundColor2
            break
            
            
        case .Disconnected:
            backgroundColor = Colors.redColor()
            label.textColor = UIColor.whiteColor()
            break
        }
        
        if let backgroundColor = backgroundColor {
            if backgroundColor.isDark() {
                spinner.activityIndicatorViewStyle = .White
            } else {
                spinner.activityIndicatorViewStyle = .Gray
            }
        }
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
    
    // MARK: Actions
    
    func didTap() {
        if status == .Disconnected {
            onTapToConnect?()
        }
    }
}
