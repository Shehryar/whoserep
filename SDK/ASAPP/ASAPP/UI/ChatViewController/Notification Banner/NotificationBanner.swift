//
//  NotificationBanner.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 2/6/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

protocol NotificationBannerDelegate: class {
    func notificationBannerDidTapExpand(_ notificationBanner: NotificationBanner)
    func notificationBannerDidTapCollapse(_ notificationBanner: NotificationBanner)
    func notificationBannerDidTapActionButton(_ notificationBanner: NotificationBanner, action: Action)
}

class NotificationBanner: UIView {
    weak var delegate: NotificationBannerDelegate?
    
    let notification: ChatMessageNotification
    let bannerContainerHeight: CGFloat = 44
    private(set) var isExpanded = false
    
    private let bannerContainer = UIView()
    private var iconView: UIImageView?
    private let titleLabel = UILabel()
    private let expandButton = UIButton()
    private let topBorder = UIView()
    private let bottomBorder = UIView()
    
    private let expandedContainer = UIView()
    private let separator = UIView()
    private let bodyLabel = UILabel()
    private let actionButton = UIButton()
    
    private let contentInsets = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
    private let expandButtonInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
    private let actionButtonInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
    
    init(notification: ChatMessageNotification) {
        self.notification = notification
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        topBorder.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        addSubview(topBorder)
        
        bottomBorder.backgroundColor = topBorder.backgroundColor
        addSubview(bottomBorder)
        
        addSubview(bannerContainer)
        
        if let icon = notification.icon?.icon {
            let imageView = UIImageView(image: icon.getImage())
            iconView = imageView
            if let iconView = self.iconView {
                bannerContainer.addSubview(iconView)
            }
        }
        
        titleLabel.numberOfLines = 1
        titleLabel.setAttributedText(notification.title, textType: .bodyBold, color: ASAPP.styles.colors.textPrimary)
        bannerContainer.addSubview(titleLabel)
        
        if notification.text != nil || notification.button != nil {
            // TODO: replace text button with icon
            updateExpandButton()
            expandButton.contentEdgeInsets = expandButtonInsets
            bannerContainer.addSubview(expandButton)
        }
        
        expandedContainer.clipsToBounds = true
        addSubview(expandedContainer)
        
        separator.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        expandedContainer.addSubview(separator)
        
        if let text = notification.text {
            bodyLabel.numberOfLines = 0
            bodyLabel.setAttributedText(text, textType: .body, color: ASAPP.styles.colors.textPrimary)
            expandedContainer.addSubview(bodyLabel)
        }
        
        if let button = notification.button,
           let buttonTitle = button.title,
           !buttonTitle.isEmpty {
            // TODO: support icon
            actionButton.updateText(buttonTitle, textStyle: ASAPP.styles.textStyles.actionButton, colors: ASAPP.styles.colors.actionButton)
            actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
            actionButton.contentEdgeInsets = actionButtonInsets
            actionButton.clipsToBounds = true
            expandedContainer.addSubview(actionButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topBorder.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
        bottomBorder.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        
        // banner container
        
        bannerContainer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bannerContainerHeight)
        
        let titleLabelLeft: CGFloat
        if let iconView = iconView {
            let iconSize = notification.icon?.size ?? CGSize(width: 21, height: 21)
            iconView.frame = CGRect(x: contentInsets.left, y: bannerContainer.frame.midY - (iconSize.height) / 2, width: iconSize.width, height: iconSize.height)
            titleLabelLeft = iconView.frame.maxX + 12
        } else {
            titleLabelLeft = contentInsets.left
        }
        
        let expandButtonSize = expandButton.sizeThatFits(CGSize(width: bannerContainer.frame.width / 2, height: bannerContainer.frame.height - contentInsets.top - contentInsets.bottom))
        expandButton.frame = CGRect(x: bannerContainer.frame.width - contentInsets.right / 2 - 100, y: contentInsets.top, width: 100, height: expandButtonSize.height)
        
        titleLabel.frame = CGRect(x: titleLabelLeft, y: contentInsets.top, width: bannerContainer.frame.width - expandButton.frame.width - contentInsets.right - contentInsets.left, height: bannerContainer.frame.height - contentInsets.top - contentInsets.bottom)
        
        // expanded container
        
        separator.frame = CGRect(x: contentInsets.left, y: 0, width: bounds.width - contentInsets.left - contentInsets.right, height: 1)
        
        let bodyLabelSize = bodyLabel.sizeThatFits(CGSize(width: bounds.width - contentInsets.left - contentInsets.right - 16, height: 0))
        bodyLabel.frame = CGRect(x: contentInsets.left + 8, y: 13, width: bodyLabelSize.width, height: bodyLabelSize.height)
        
        let buttonPadding: CGFloat = bodyLabel.superview != nil ? 24 : 0
        let actionButtonSize = actionButton.sizeThatFits(CGSize(width: bounds.width - contentInsets.left - contentInsets.right, height: 0))
        actionButton.frame = CGRect(x: bounds.midX - actionButtonSize.width / 2, y: bodyLabel.frame.maxY + buttonPadding, width: actionButtonSize.width, height: actionButtonSize.height)
        actionButton.layer.cornerRadius = actionButton.frame.height / 2
        
        expandedContainer.frame = CGRect(x: 0, y: bannerContainer.frame.maxY, width: bounds.width, height: bounds.height - bannerContainerHeight)
    }
    
    private func calculateExpandedContainerHeight() -> CGFloat {
        let hasBodyLabel = bodyLabel.superview != nil
        let bodyLabelHeight = hasBodyLabel ? 13 + bodyLabel.sizeThatFits(CGSize(width: bounds.width - contentInsets.left - contentInsets.right - 16, height: 0)).height : 0
        let actionButtonHeight = actionButton.superview != nil
            ? (hasBodyLabel ? 24 : 0) + actionButton.sizeThatFits(CGSize(width: bounds.width - contentInsets.left - contentInsets.right, height: 0)).height
            : 0
        return bodyLabelHeight + actionButtonHeight + 24
    }
    
    private func updateExpandButton() {
        expandButton.removeTarget(self, action: nil, for: .allTouchEvents)
        let textStyle = ASAPPTextStyle(font: Fonts.default.bold, size: 12, letterSpacing: 1, color: ASAPP.styles.colors.textPrimary, uppercase: true)
        let colors = ASAPPButtonColors(textColor: ASAPP.styles.colors.textPrimary)
        
        if isExpanded {
            expandButton.addTarget(self, action: #selector(didTapCollapseButton), for: .touchUpInside)
            expandButton.updateText("Collapse", textStyle: textStyle, colors: colors)
        } else {
            expandButton.addTarget(self, action: #selector(didTapExpandButton), for: .touchUpInside)
            expandButton.updateText("Expand", textStyle: textStyle, colors: colors)
        }
    }
    
    @objc func didTapExpandButton() {
        isExpanded = true
        updateExpandButton()
        delegate?.notificationBannerDidTapExpand(self)
    }
    
    @objc func didTapCollapseButton() {
        isExpanded = false
        updateExpandButton()
        delegate?.notificationBannerDidTapCollapse(self)
    }
    
    @objc func didTapActionButton() {
        guard let action = notification.button?.action else { return }
        delegate?.notificationBannerDidTapActionButton(self, action: action)
    }
    
    func preferredDisplayHeight() -> CGFloat {
        return bannerContainerHeight + (isExpanded ? calculateExpandedContainerHeight() : 0)
    }
}
