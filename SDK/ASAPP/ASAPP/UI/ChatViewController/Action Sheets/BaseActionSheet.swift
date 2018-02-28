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

    init(title: String?, body: String, hideButtonTitle: String, restartButtonTitle: String) {
        super.init(frame: .zero)
        
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

        contentView.backgroundColor = .white
        addSubview(contentView)
        
        if let title = title {
            titleLabel.numberOfLines = 0
            titleLabel.setAttributedText(title, textStyle: ASAPP.styles.textStyles.header2, color: ASAPP.styles.colors.textPrimary)
            contentView.addSubview(titleLabel)
        }
        
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
        
        let path = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 6, height: 6))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        contentView.layer.mask = mask
        
        let contentFitSize = CGSize(width: contentView.frame.width - contentInsets.left - contentInsets.right, height: 0)
        
        let hasTitleLabel = titleLabel.superview != nil
        let titleLabelSize = hasTitleLabel ? titleLabel.sizeThatFits(contentFitSize) : .zero
        titleLabel.frame = CGRect(x: contentInsets.left, y: contentInsets.top, width: titleLabelSize.width, height: titleLabelSize.height)
        
        let bodyLabelPadding: CGFloat = hasTitleLabel ? 10 : 0
        let bodyLabelSize = bodyLabel.sizeThatFits(contentFitSize)
        bodyLabel.frame = CGRect(x: contentInsets.left, y: titleLabel.frame.maxY + bodyLabelPadding, width: bodyLabelSize.width, height: bodyLabelSize.height)
        
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
    
    func show(in parent: UIView) {
        parent.addSubview(self)
        frame = parent.bounds
        alpha = 0
        setNeedsLayout()
        layoutIfNeeded()
        
        let contentViewFinalFrame = contentView.frame
        
        var contentViewStartFrame = contentView.frame
        contentViewStartFrame.origin.y = parent.bounds.maxY
        contentView.frame = contentViewStartFrame
        
        titleLabel.alpha = 0
        bodyLabel.alpha = 0
        hideButton.alpha = 0
        restartButton.alpha = 0
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.contentView.frame = contentViewFinalFrame
            }
            
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                self?.titleLabel.alpha = 1
                self?.bodyLabel.alpha = 1
                self?.hideButton.alpha = 1
                self?.restartButton.alpha = 1
            }, completion: nil)
        })
    }
    
    func hide(_ completion: (() -> Void)? = nil) {
        var contentViewFinalFrame = contentView.frame
        contentViewFinalFrame.origin.y = contentView.frame.maxY
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.contentView.frame = contentViewFinalFrame
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.alpha = 0
            }, completion: { [weak self] _ in
                self?.removeFromSuperview()
                completion?()
            })
        })
    }
    
    func showSpinner() {
        restartButton.isEnabled = false
        
        activityIndicator = UIActivityIndicatorView(frame: restartButton.frame)
        if let spinner = activityIndicator {
            spinner.backgroundColor = .clear
            spinner.activityIndicatorViewStyle = .gray
            spinner.frame = restartButton.frame
            contentView.insertSubview(spinner, belowSubview: restartButton)
            spinner.startAnimating()
            spinner.alpha = 0
        }
        
        var finalButtonFrame = restartButton.frame
        finalButtonFrame.size.width = restartButton.frame.size.height
        finalButtonFrame.origin.x += (restartButton.frame.size.width - finalButtonFrame.size.width) / 2
        
        let rotation = CGAffineTransform(rotationAngle: .pi / -2)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {[weak self] in
            guard let button = self?.restartButton else { return }
            button.frame = finalButtonFrame
        }, completion: nil)
        
        UIView.animate(withDuration: 0.6) { [weak self] in
            guard let button = self?.restartButton else { return }
            self?.activityIndicator?.alpha = 1
            button.transform = rotation
            button.alpha = 0
        }
    }
    
    func hideSpinner() {
        activityIndicator?.removeFromSuperview()
        restartButton.isEnabled = true
        restartButton.titleLabel?.alpha = 1
        restartButton.transform = .identity
        restartButton.alpha = 1
        restartButton.updateBackgroundColors(ASAPP.styles.colors.actionButton)
        setNeedsLayout()
        layoutIfNeeded()
    }
}
