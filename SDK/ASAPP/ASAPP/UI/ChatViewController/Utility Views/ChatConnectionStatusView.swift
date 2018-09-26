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
                
            case .connecting:
                spinner.startAnimating()
                message = ASAPP.strings.connectionBannerConnecting
                
            case .disconnected:
                spinner.stopAnimating()
                message = ASAPP.strings.connectionBannerDisconnected
            }
        }
    }
    
    override var isHidden: Bool {
        didSet {
            configureAccessibility()
        }
    }
    
    var onTapToConnect: (() -> Void)?
    
    // MARK: Private Properties
    
    let label = UILabel()
    
    private let spinner = UIActivityIndicatorView()
    
    private let contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    
    // MARK: Init

    required init() {
        super.init(frame: .zero)
        
        updateColors()
        updateDisplay()
        
        addSubview(label)
        addSubview(spinner)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChatConnectionStatusView.didTap)))
        
        configureAccessibility()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Styling
    
    func updateColors() {
        switch status {
        case .connected:
            backgroundColor = UIColor.ASAPP.snow
            label.textColor = ASAPP.styles.colors.textSecondary
            
        case .connecting:
            backgroundColor = UIColor.ASAPP.snow
            label.textColor = ASAPP.styles.colors.textSecondary
            
        case .disconnected:
            backgroundColor = UIColor.ASAPP.errorRed
            label.textColor = UIColor.white
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
        label.font = ASAPP.styles.textStyles.detail1.font.changingOnlySize(15)
        label.textAlignment = .center
        
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    private struct CalculatedLayout {
        let spinnerFrame: CGRect
        let labelFrame: CGRect
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        let spinnerSize = spinner.sizeThatFits(size)
        let spinnerFrame = CGRect(
            x: round(size.width - contentInset.right - spinnerSize.width),
            y: round(size.height / 2 - spinnerSize.height / 2),
            width: spinnerSize.width,
            height: spinnerSize.height)
        
        let horizontalInset = size.width - spinnerFrame.minX - 8
        let labelSize = label.sizeThatFits(CGSize(width: size.width - 2 * horizontalInset, height: size.height))
        let labelFrame = CGRect(
            x: round(size.width / 2 - labelSize.width / 2),
            y: round(size.height / 2 - labelSize.height / 2),
            width: labelSize.width,
            height: labelSize.height)
        
        return CalculatedLayout(spinnerFrame: spinnerFrame, labelFrame: labelFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateColors()
        updateFrames()
    }
    
    func updateFrames(in bounds: CGRect? = nil) {
        let bounds = bounds ?? self.bounds
        let layout = getFramesThatFit(bounds.size)
        
        spinner.frame = layout.spinnerFrame
        label.frame = layout.labelFrame
        
        configureAccessibility()
    }
    
    func configureAccessibility() {
        isAccessibilityElement = true
        if !isHidden {
            accessibilityLabel = message
            accessibilityTraits = (status == .disconnected) ? UIAccessibilityTraitButton : UIAccessibilityTraitNone
        } else {
            accessibilityLabel = nil
            accessibilityTraits = UIAccessibilityTraitNone
        }
    }
    
    // MARK: Actions
    
    @objc func didTap() {
        if status == .disconnected {
            onTapToConnect?()
        }
    }
}
