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
    private let blurredBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let hideButton = UIButton()
    private let restartButton = UIButton()
    private var activityIndicator: UIActivityIndicatorView?
    
    private let sheetInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private let contentInsets = UIEdgeInsets(top: 43, left: 24, bottom: 48, right: 24)
    private let buttonInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
    
    private var hasTitleLabel: Bool {
        return titleLabel.superview != nil
    }
    
    private var bodyLabelPadding: CGFloat {
        return hasTitleLabel ? 17 : 0
    }

    init(title: String?, body: String, hideButtonTitle: String, restartButtonTitle: String) {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        addSubview(blurredBackground)

        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        addSubview(contentView)
        
        if let title = title {
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.setAttributedText(title, textStyle: ASAPP.styles.textStyles.header1)
            contentView.addSubview(titleLabel)
        }
        
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center
        bodyLabel.setAttributedText(body, textStyle: ASAPP.styles.textStyles.body2, color: ASAPP.styles.colors.dark.withAlphaComponent(0.8))
        contentView.addSubview(bodyLabel)
        
        let actionColors = ASAPP.styles.colors.actionButton
        restartButton.addTarget(self, action: #selector(didTapRestartButton), for: .touchUpInside)
        restartButton.updateText(restartButtonTitle, textStyle: ASAPP.styles.textStyles.actionButton, colors: actionColors)
        restartButton.setTitleShadow(opacity: 0.18)
        restartButton.contentEdgeInsets = buttonInsets
        restartButton.clipsToBounds = true
        restartButton.layer.shadowColor = UIColor.ASAPP.lakeMinnetonka.cgColor
        restartButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        restartButton.layer.shadowRadius = 20
        restartButton.layer.shadowOpacity = 0.25
        contentView.addSubview(restartButton)
        
        let inverseColors = ASAPPButtonColors(backgroundColor: actionColors.textNormal.withAlphaComponent(0.1), textColor: actionColors.backgroundNormal, border: actionColors.border)
        hideButton.addTarget(self, action: #selector(didTapHideButton), for: .touchUpInside)
        hideButton.updateText(hideButtonTitle, textStyle: ASAPP.styles.textStyles.actionButton, colors: inverseColors)
        hideButton.setTitleShadow(opacity: 0.18)
        hideButton.contentEdgeInsets = buttonInsets
        hideButton.clipsToBounds = true
        hideButton.layer.shadowColor = UIColor.ASAPP.lakeMinnetonka.cgColor
        hideButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        hideButton.layer.shadowRadius = 20
        hideButton.layer.shadowOpacity = 0.25
        contentView.addSubview(hideButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurredBackground.frame = bounds
        
        let contentWidth = frame.width - sheetInsets.left - sheetInsets.right
        let contentFitSize = CGSize(width: contentWidth - contentInsets.left - contentInsets.right, height: 0)
        
        let titleLabelSize = hasTitleLabel ? titleLabel.sizeThatFits(contentFitSize) : .zero
        titleLabel.frame = CGRect(x: contentInsets.left, y: contentInsets.top, width: contentFitSize.width, height: titleLabelSize.height)
        
        let bodyLabelSize = bodyLabel.sizeThatFits(contentFitSize)
        bodyLabel.frame = CGRect(x: contentInsets.left, y: titleLabel.frame.maxY + bodyLabelPadding, width: contentFitSize.width, height: bodyLabelSize.height)
        
        let restartButtonSize = restartButton.sizeThatFits(contentFitSize)
        restartButton.frame = CGRect(x: contentWidth / 2 - restartButtonSize.width / 2, y: bodyLabel.frame.maxY + 36, width: restartButtonSize.width, height: restartButtonSize.height)
        restartButton.layer.cornerRadius = restartButtonSize.height / 2
        
        let hideButtonSize = hideButton.sizeThatFits(contentFitSize)
        hideButton.frame = CGRect(x: contentWidth / 2 - hideButtonSize.width / 2, y: restartButton.frame.maxY + 10, width: hideButtonSize.width, height: hideButtonSize.height)
        hideButton.layer.cornerRadius = hideButtonSize.height / 2
        
        let totalHeight = hideButton.frame.maxY + contentInsets.bottom
        contentView.frame = CGRect(x: sheetInsets.left, y: frame.maxY - totalHeight, width: contentWidth, height: totalHeight)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchesOutOfSheet(touches) {
            delegate?.actionSheetDidTapHideButton(self)
        }
    }
 
    func touchesOutOfSheet(_ touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else { return false }
        
        let touchLocation = touch.location(in: self)
        let touchableArea = bounds.divided(atDistance: contentView.frame.height, from: .maxYEdge).remainder
        
        return touchableArea.contains(touchLocation)
    }
    
    @objc func didTapHideButton() {
        delegate?.actionSheetDidTapHideButton(self)
    }
    
    @objc func didTapRestartButton() {
        delegate?.actionSheetDidTapRestartButton(self)
    }
    
    func show(in parent: UIView, below other: UIView? = nil) {
        if let other = other {
            parent.insertSubview(self, belowSubview: other)
        } else {
            parent.addSubview(self)
        }
        frame = parent.bounds
        setNeedsLayout()
        layoutIfNeeded()
        
        let contentViewFinalFrame = contentView.frame
        
        var contentViewStartFrame = contentView.frame
        contentViewStartFrame.origin.y = parent.bounds.maxY
        contentView.frame = contentViewStartFrame
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.contentView.frame = contentViewFinalFrame
        }
    }
    
    func hide(_ completion: (() -> Void)? = nil) {
        var contentViewFinalFrame = contentView.frame
        contentViewFinalFrame.origin.y = contentView.frame.maxY
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.contentView.frame = contentViewFinalFrame
        }, completion: { [weak self] _ in
            self?.removeFromSuperview()
            completion?()
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
