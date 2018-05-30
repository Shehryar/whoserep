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
    var shouldHide = false {
        didSet {
            if oldValue != shouldHide {
                bannerContainer.clipsToBounds = true
            }
        }
    }
    private(set) var isExpanded = false
    
    private let bannerContainer = UIView()
    private var iconView: UIImageView?
    private let titleLabel = UILabel()
    private let expandIcon = UIImageView()
    private let bottomBorder = UIView()
    private let overlayButton = UIButton()
    
    private let expandedContainer = UIView()
    private let separator = UIView()
    private let bodyLabel = UILabel()
    private let actionButton = UIButton()
    
    private let expandIconSize = CGSize(width: 24, height: 24)
    private let exitIconSize = CGSize(width: 16, height: 16)
    
    private let contentInsets = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
    private let expandButtonInsets = UIEdgeInsets(top: 6, left: 12, bottom: 4, right: 12)
    private let actionButtonInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    init(notification: ChatMessageNotification) {
        self.notification = notification
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        bannerContainer.backgroundColor = .white
        addSubview(bannerContainer)
        
        bottomBorder.backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
        addSubview(bottomBorder)
        
        if let icon = notification.icon?.icon {
            let imageView = UIImageView(image: icon.getImage()?.tinted(ASAPP.styles.colors.iconTint))
            iconView = imageView
            if let iconView = self.iconView {
                bannerContainer.addSubview(iconView)
            }
        }
        
        titleLabel.numberOfLines = 1
        titleLabel.setAttributedText(notification.title, textType: .body, color: ASAPP.styles.colors.dark)
        bannerContainer.addSubview(titleLabel)
        
        if notification.text != nil || notification.button != nil {
            expandIcon.image = Images.getImage(.iconChevron)?.tinted(ASAPP.styles.colors.primary)
            updateExpandIcon()
            bannerContainer.addSubview(expandIcon)
            addSubview(overlayButton)
        }
        
        expandedContainer.clipsToBounds = true
        insertSubview(expandedContainer, belowSubview: bannerContainer)
        
        separator.backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
        expandedContainer.addSubview(separator)
        
        if let text = notification.text {
            bodyLabel.numberOfLines = 0
            bodyLabel.setAttributedText(text, textType: .body, color: ASAPP.styles.colors.dark.withAlphaComponent(0.8))
            expandedContainer.addSubview(bodyLabel)
        }
        
        if let button = notification.button,
           let buttonTitle = button.title,
           !buttonTitle.isEmpty,
           let titleLabel = actionButton.titleLabel {
            actionButton.contentHorizontalAlignment = .left
            actionButton.updateText(buttonTitle, textStyle: ASAPP.styles.textStyles.body, colors: ASAPP.styles.colors.textButtonPrimary)
            titleLabel.layer.shadowColor = ASAPP.styles.colors.textButtonPrimary.textNormal.withAlphaComponent(0.15).cgColor
            titleLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
            titleLabel.layer.shadowOpacity = 1
            titleLabel.layer.shadowRadius = 3
            if button.action.willExitASAPP {
                actionButton.imageEdgeInsets.right = -6
                actionButton.imageEdgeInsets.left = 6
                actionButton.setImage(Images.getImage(.iconExitLink)?.tinted(ASAPP.styles.colors.textButtonPrimary.textNormal), for: .normal)
                actionButton.semanticContentAttribute = .forceRightToLeft
                actionButton.imageView?.layer.shadowColor = titleLabel.layer.shadowColor
                actionButton.imageView?.layer.shadowOffset = titleLabel.layer.shadowOffset
                actionButton.imageView?.layer.shadowOpacity = titleLabel.layer.shadowOpacity
                actionButton.imageView?.layer.shadowRadius = titleLabel.layer.shadowRadius
            }
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
        
        bottomBorder.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        
        // banner container
        
        bannerContainer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bannerContainerHeight)
        overlayButton.frame = bannerContainer.frame
        
        let titleLabelLeft: CGFloat
        if let iconView = iconView {
            let iconSize = notification.icon?.size ?? CGSize(width: 21, height: 21)
            iconView.frame = CGRect(x: contentInsets.left, y: 1 + bannerContainer.frame.midY - (iconSize.height) / 2, width: iconSize.width, height: iconSize.height)
            titleLabelLeft = iconView.frame.maxX + 12
        } else {
            titleLabelLeft = contentInsets.left
        }
        
        let availableHeight = bannerContainer.frame.height - contentInsets.top - contentInsets.bottom
        expandIcon.frame = CGRect(x: bannerContainer.frame.width - contentInsets.right - expandIconSize.width, y: contentInsets.top, width: expandIconSize.width, height: expandIconSize.height)
        
        titleLabel.frame = CGRect(x: titleLabelLeft, y: contentInsets.top, width: bannerContainer.frame.width - expandIcon.frame.width - contentInsets.right - contentInsets.left, height: availableHeight)
        
        // expanded container
        
        separator.frame = CGRect(x: contentInsets.left, y: 0, width: bounds.width - contentInsets.left - contentInsets.right, height: 1)
        
        let bodyLabelSize = bodyLabel.sizeThatFits(CGSize(width: bounds.width - contentInsets.left - contentInsets.right - 16, height: 0))
        bodyLabel.frame = CGRect(x: contentInsets.left + 8, y: 26, width: bodyLabelSize.width, height: bodyLabelSize.height)
        
        let buttonPadding: CGFloat = bodyLabel.superview != nil ? 24 : 0
        let actionButtonSize = actionButton.sizeThatFits(CGSize(width: bounds.width - contentInsets.left - contentInsets.right, height: 0))
        actionButton.frame = CGRect(x: bodyLabel.frame.minX - actionButtonInsets.left, y: bodyLabel.frame.maxY + buttonPadding, width: actionButtonSize.width, height: actionButtonSize.height)
        
        let expandedHeight = calculateExpandedContainerHeight()
        expandedContainer.frame = CGRect(x: 0, y: bannerContainer.frame.maxY - (isExpanded ? 0 : expandedHeight), width: bounds.width, height: expandedHeight)
        
        bannerContainer.alpha = shouldHide ? 0 : 1
        expandedContainer.isHidden = shouldHide
    }
    
    private func calculateExpandedContainerHeight() -> CGFloat {
        let hasBodyLabel = bodyLabel.superview != nil
        let bodyLabelHeight = hasBodyLabel ? bodyLabel.sizeThatFits(CGSize(width: bounds.width - contentInsets.left - contentInsets.right - 16, height: 0)).height : 0
        let actionButtonHeight = actionButton.superview != nil
            ? (hasBodyLabel ? 24 : 0) + actionButton.sizeThatFits(CGSize(width: bounds.width - contentInsets.left - contentInsets.right, height: 0)).height
            : 0
        return 26 + bodyLabelHeight + actionButtonHeight + 24
    }
    
    private func updateExpandIcon() {
        overlayButton.removeTarget(self, action: nil, for: .allTouchEvents)
        
        if isExpanded {
            overlayButton.addTarget(self, action: #selector(didTapCollapse), for: .touchUpInside)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.expandIcon.transform = CGAffineTransform(rotationAngle: .pi)
            }
        } else {
            overlayButton.addTarget(self, action: #selector(didTapExpand), for: .touchUpInside)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.expandIcon.transform = .identity
            }
        }
    }
    
    @objc func didTapExpand() {
        isExpanded = true
        updateExpandIcon()
        delegate?.notificationBannerDidTapExpand(self)
    }
    
    @objc func didTapCollapse() {
        isExpanded = false
        updateExpandIcon()
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
