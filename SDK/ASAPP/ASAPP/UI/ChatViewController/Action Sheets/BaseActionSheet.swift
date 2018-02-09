//
//  BaseActionSheet.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 2/5/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

protocol ActionSheetDelegate: class {
    func actionSheetDidTapHideButton(_ actionSheet: BaseActionSheet)
    func actionSheetDidTapRestartButton(_ actionSheet: BaseActionSheet)
}

class BaseActionSheet: UIView {
    weak var delegate: ActionSheetDelegate?
    
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let hideButton = UIButton()
    private let restartButton = UIButton()
    private var activityIndicator: UIActivityIndicatorView?
    
    private let sheetInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    private let contentInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
    private let buttonInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)

    init(title: String, body: String, hideButtonTitle: String, restartButtonTitle: String) {
        super.init(frame: .zero)
        
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 6
        addSubview(contentView)
        
        titleLabel.numberOfLines = 0
        titleLabel.setAttributedText(title, textStyle: ASAPP.styles.textStyles.header2, color: ASAPP.styles.colors.textPrimary)
        contentView.addSubview(titleLabel)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.setAttributedText(body, textStyle: ASAPP.styles.textStyles.body, color: ASAPP.styles.colors.textPrimary)
        contentView.addSubview(bodyLabel)
        
        hideButton.addTarget(self, action: #selector(didTapHideButton), for: .touchUpInside)
        hideButton.updateText(hideButtonTitle, textStyle: ASAPP.styles.textStyles.actionButton, colors: ASAPP.styles.colors.actionButton)
        hideButton.contentEdgeInsets = buttonInsets
        hideButton.clipsToBounds = true
        contentView.addSubview(hideButton)
        
        restartButton.addTarget(self, action: #selector(didTapRestartButton), for: .touchUpInside)
        restartButton.updateText(restartButtonTitle, textStyle: ASAPP.styles.textStyles.actionButton, colors: ASAPP.styles.colors.actionButton)
        restartButton.contentEdgeInsets = buttonInsets
        restartButton.clipsToBounds = true
        contentView.addSubview(restartButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = CGRect(x: sheetInsets.left, y: frame.midY, width: frame.width - sheetInsets.left - sheetInsets.right, height: frame.maxY - frame.midY)
        
        let contentFitSize = CGSize(width: contentView.frame.width - contentInsets.left - contentInsets.right, height: 0)
        
        let titleLabelSize = titleLabel.sizeThatFits(contentFitSize)
        titleLabel.frame = CGRect(x: contentInsets.left, y: contentInsets.top, width: titleLabelSize.width, height: titleLabelSize.height)
        
        let bodyLabelSize = bodyLabel.sizeThatFits(contentFitSize)
        bodyLabel.frame = CGRect(x: contentInsets.left, y: titleLabel.frame.maxY + 10, width: bodyLabelSize.width, height: bodyLabelSize.height)
        
        let hideButtonSize = hideButton.sizeThatFits(contentFitSize)
        hideButton.frame = CGRect(x: contentView.frame.width / 2 - hideButtonSize.width / 2, y: bodyLabel.frame.maxY + 30, width: hideButtonSize.width, height: hideButtonSize.height)
        hideButton.layer.cornerRadius = hideButtonSize.height / 2
        
        let restartButtonSize = restartButton.sizeThatFits(contentFitSize)
        restartButton.frame = CGRect(x: contentView.frame.width / 2 - restartButtonSize.width / 2, y: hideButton.frame.maxY + 10, width: restartButtonSize.width, height: restartButtonSize.height)
        restartButton.layer.cornerRadius = restartButtonSize.height / 2
    }
    
    @objc func didTapHideButton() {
        delegate?.actionSheetDidTapHideButton(self)
    }
    
    @objc func didTapRestartButton() {
        delegate?.actionSheetDidTapRestartButton(self)
    }
    
    func showSpinner() {
        restartButton.isEnabled = false
        restartButton.titleLabel?.alpha = 0
        
        activityIndicator = UIActivityIndicatorView(frame: restartButton.bounds)
        if let spinner = activityIndicator {
            spinner.activityIndicatorViewStyle = .gray
            restartButton.addSubview(spinner)
            spinner.startAnimating()
        }
        
        restartButton.setNeedsLayout()
        restartButton.layoutIfNeeded()
    }
    
    func hideSpinner() {
        activityIndicator?.removeFromSuperview()
        restartButton.isEnabled = true
        restartButton.titleLabel?.alpha = 1
        restartButton.setNeedsLayout()
        restartButton.layoutIfNeeded()
    }
}
