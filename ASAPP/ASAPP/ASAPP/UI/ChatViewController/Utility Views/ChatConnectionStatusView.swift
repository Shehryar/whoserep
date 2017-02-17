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

class ChatConnectionStatusView: UIView {
    
    var message: String? {
        didSet {
            label.text = message
            setNeedsLayout()
        }
    }
    
    var status: ChatConnectionStatus = .disconnected {
        didSet {
            switch status {
            case .connected:
                spinner.stopAnimating()
                message =  ASAPP.strings.connectionBannerConnected
                break
                
            case .connecting:
                spinner.startAnimating()
                message = ASAPP.strings.connectionBannerConnecting
                break
                
                
            case .disconnected:
                spinner.stopAnimating()
                message = ASAPP.strings.connectionBannerDisconnected
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


    required init() {
        super.init(frame: .zero)
        
        updateColors()
        updateDisplay()
        
        addSubview(label)
        addSubview(spinner)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChatConnectionStatusView.didTap)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Styling
    
    func updateColors() {
        switch status {
        case .connected:
            backgroundColor = ASAPP.styles.backgroundColor2
            label.textColor = ASAPP.styles.foregroundColor2
            break
            
        case .connecting:
            backgroundColor = ASAPP.styles.backgroundColor2
            label.textColor = ASAPP.styles.foregroundColor2
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
    
    func updateDisplay() {
        label.updateFont(for: .connectionStatusBanner, styles: ASAPP.styles)
        label.textAlignment = .center
        
        setNeedsLayout()
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
