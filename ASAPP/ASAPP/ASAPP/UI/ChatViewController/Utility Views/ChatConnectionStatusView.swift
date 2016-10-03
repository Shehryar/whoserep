//
//  ChatConnectionStatusView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum ChatConnectionStatus {
    case connected
    case connecting
    case disconnected
}

class ChatConnectionStatusView: UIView, ASAPPStyleable {

    var message: String? {
        didSet {
            label.text = message
        }
    }
    
    var status: ChatConnectionStatus = .disconnected {
        didSet {
            switch status {
            case .connected:
                spinner.stopAnimating()
                message =  ASAPPLocalizedString("Connection Established")
                break
                
            case .connecting:
                spinner.startAnimating()
                message = ASAPPLocalizedString("Connecting...")
                break
                
                
            case .disconnected:
                spinner.stopAnimating()
                message = ASAPPLocalizedString("Not connected. Retry connection?")
                break
            }
            
            updateColors()
        }
    }
    
    var onTapToConnect: (() -> Void)?
    
    // MARK: Private Properties
    
    fileprivate let label = UILabel()
    
    fileprivate let spinner = UIActivityIndicatorView()
    
    fileprivate let contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
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
    
    fileprivate(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
    
        label.font = styles.detailFont
        label.textAlignment = .center
        
        updateColors()
    }
    
    func updateColors() {
        switch status {
        case .connected:
            backgroundColor = styles.backgroundColor2
            label.textColor = styles.foregroundColor2
            break
            
        case .connecting:
            backgroundColor = styles.backgroundColor2
            label.textColor = styles.foregroundColor2
            break
            
            
        case .disconnected:
            backgroundColor = Colors.redColor()
            label.textColor = UIColor.white
            break
        }
        
        if let backgroundColor = backgroundColor {
            if backgroundColor.isDark() {
                spinner.activityIndicatorViewStyle = .white
            } else {
                spinner.activityIndicatorViewStyle = .gray
            }
        }
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        spinner.sizeToFit()
        spinner.center = CGPoint(x: bounds.width - contentInset.right - spinner.bounds.width / 2.0,
                                 y: bounds.midY)
        
        let horizontalInset = bounds.width - spinner.frame.minX - 8.0
        let labelWidth = bounds.width - 2 * horizontalInset
        label.frame = CGRect(x: horizontalInset, y: 0, width: labelWidth, height: bounds.height)
    }
    
    // MARK: Actions
    
    func didTap() {
        if status == .disconnected {
            onTapToConnect?()
        }
    }
}
