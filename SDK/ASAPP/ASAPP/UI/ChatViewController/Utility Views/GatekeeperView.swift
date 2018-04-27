//
//  GatekeeperView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 4/23/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

protocol GatekeeperViewDelegate: class {
    func gatekeeperViewDidTapLogIn(_ gatekeeperView: GatekeeperView)
    func gatekeeperViewDidTapReconnect(_ gatekeeperView: GatekeeperView)
}

class GatekeeperView: UIView {
    enum ContentType {
        case unauthenticated
        case notConnected
    }
    
    weak var delegate: GatekeeperViewDelegate?
    
    private let iconView = UIImageView()
    private var iconSize: CGSize = .zero
    private let promptLabel = UILabel()
    private let button = UIButton()
    private var activityIndicator: UIActivityIndicatorView?
    private let buttonAnimationDuration: TimeInterval = 0.3
    
    required init(contentType: ContentType) {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        addSubview(iconView)
        
        promptLabel.textAlignment = .center
        promptLabel.textColor = ASAPP.styles.colors.dark
        promptLabel.font = ASAPP.styles.textStyles.body.font.withSize(18)
        addSubview(promptLabel)
        
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        button.clipsToBounds = true
        button.layer.cornerRadius = 12
        button.updateBackgroundColors(ASAPP.styles.colors.buttonPrimary)
        addSubview(button)
        
        update(for: contentType)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update(for contentType: ContentType) {
        button.removeTarget(nil, action: nil, for: .allEvents)
        
        switch contentType {
        case .unauthenticated:
            iconView.image = ComponentIcon.getImage(.user)
            iconSize = CGSize(width: 33, height: 33)
            promptLabel.text = ASAPPLocalizedString("Please log in to continue")
            button.updateText(ASAPPLocalizedString("Log in"), textStyle: ASAPP.styles.textStyles.button, colors: ASAPP.styles.colors.buttonPrimary)
            button.addTarget(self, action: #selector(didTapLogIn), for: .touchUpInside)
        case .notConnected:
            iconView.image = ComponentIcon.getImage(.alertError)
            iconSize = CGSize(width: 41, height: 36)
            promptLabel.text = ASAPPLocalizedString("Unable to reconnect")
            button.updateText(ASAPPLocalizedString("Retry connecting"), textStyle: ASAPP.styles.textStyles.button, colors: ASAPP.styles.colors.buttonPrimary)
            button.addTarget(self, action: #selector(didTapReconnect), for: .touchUpInside)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconView.frame = CGRect(x: bounds.width / 2 - iconSize.width / 2, y: bounds.height / 2 - iconSize.height, width: iconSize.width, height: iconSize.height)
        
        let promptLabelSize = promptLabel.sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        promptLabel.frame = CGRect(x: bounds.width / 2 - promptLabelSize.width / 2, y: iconView.frame.maxY + 20, width: promptLabelSize.width, height: promptLabelSize.height)
        
        let buttonSize = button.sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        button.frame = CGRect(x: bounds.width / 2 - buttonSize.width / 2, y: bounds.height - 50 - buttonSize.height, width: buttonSize.width, height: buttonSize.height)
    }
    
    @objc func didTapLogIn() {
        showSpinner()
        delegate?.gatekeeperViewDidTapLogIn(self)
    }
    
    @objc func didTapReconnect() {
        showSpinner()
        delegate?.gatekeeperViewDidTapReconnect(self)
    }
    
    func showSpinner() {
        button.isEnabled = false
        
        activityIndicator = UIActivityIndicatorView(frame: button.frame)
        if let spinner = activityIndicator {
            spinner.backgroundColor = .clear
            spinner.activityIndicatorViewStyle = .gray
            spinner.frame = button.frame
            insertSubview(spinner, belowSubview: button)
            spinner.startAnimating()
            spinner.alpha = 0
        }
        
        UIView.animate(withDuration: buttonAnimationDuration, animations: { [weak self] in
            self?.activityIndicator?.alpha = 1
            self?.button.alpha = 0
        }, completion: { _ in
            Dispatcher.delay(3000) { [weak self] in
                self?.activityIndicator?.removeFromSuperview()
                self?.button.alpha = 1
                self?.button.isEnabled = true
            }
        })
    }
}
