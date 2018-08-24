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
    func notificationBannerDidTapDismiss(_ notificationBanner: NotificationBanner, button: QuickReply)
    func notificationBannerDidTapActionButton(_ notificationBanner: NotificationBanner, button: QuickReply)
}

class NotificationBanner: UIView {
    weak var delegate: NotificationBannerDelegate?
    
    let notification: ChatNotification
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
    private let dismissButton = UIButton()
    private let buttonSeparator = UIView()
    private let actionButton = UIButton()
    
    private let expandIconSize = CGSize(width: 24, height: 24)
    private let exitIconSize = CGSize(width: 16, height: 16)
    
    private let contentInsets = UIEdgeInsets(top: 10, left: 22, bottom: 10, right: 22)
    private let expandButtonInsets = UIEdgeInsets(top: 6, left: 12, bottom: 4, right: 12)
    private let textButtonInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    init(notification: ChatNotification) {
        self.notification = notification
        
        super.init(frame: .zero)
        
        backgroundColor = UIColor.ASAPP.snow
        
        let mask = CALayer()
        mask.backgroundColor = UIColor.black.cgColor
        mask.frame = CGRect(x: 0, y: 0, width: superview?.frame.width ?? 1000, height: superview?.frame.height ?? 1000)
        layer.mask = mask
        
        bannerContainer.backgroundColor = UIColor.ASAPP.snow
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
            expandIcon.image = Images.getImage(.iconChevron)?.tinted(ASAPP.styles.colors.dark)
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
        
        dismissButton.updateText(ASAPP.strings.notificationBannerDismissButton, textStyle: ASAPP.styles.textStyles.body2, colors: ASAPP.styles.colors.textButtonPrimary)
        configureButton(dismissButton)
        dismissButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
        expandedContainer.addSubview(dismissButton)
        
        guard let button = notification.button,
              !button.title.isEmpty,
              let titleLabel = actionButton.titleLabel else {
            return
        }
        
        buttonSeparator.backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
        expandedContainer.addSubview(buttonSeparator)
        
        actionButton.updateText(button.title, textStyle: ASAPP.styles.textStyles.body2, colors: ASAPP.styles.colors.textButtonPrimary)
        configureButton(actionButton)
        if button.action.willExitASAPP {
            let imageInset: CGFloat = 8
            actionButton.imageEdgeInsets.right = -imageInset
            actionButton.imageEdgeInsets.left = imageInset
            actionButton.contentEdgeInsets.right += imageInset
            actionButton.setImage(Images.getImage(.iconExitLink)?.tinted(ASAPP.styles.colors.textButtonPrimary.textNormal), for: .normal)
            actionButton.semanticContentAttribute = .forceRightToLeft
            actionButton.imageView?.layer.shadowColor = titleLabel.layer.shadowColor
            actionButton.imageView?.layer.shadowOffset = titleLabel.layer.shadowOffset
            actionButton.imageView?.layer.shadowOpacity = titleLabel.layer.shadowOpacity
            actionButton.imageView?.layer.shadowRadius = titleLabel.layer.shadowRadius
        }
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        expandedContainer.addSubview(actionButton)
    }
    
    private func configureButton(_ button: UIButton) {
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = textButtonInsets
        button.clipsToBounds = true
        
        guard let titleLabel = button.titleLabel else {
            return
        }
        
        titleLabel.layer.shadowColor = ASAPP.styles.colors.textButtonPrimary.textNormal.withAlphaComponent(0.15).cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowRadius = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDisplay() {
        titleLabel.setAttributedText(notification.title, textType: .body, color: ASAPP.styles.colors.dark)
        if let text = notification.text {
            bodyLabel.setAttributedText(text, textType: .body, color: ASAPP.styles.colors.dark.withAlphaComponent(0.8))
        }
        if let button = notification.button {
            actionButton.updateText(button.title, textStyle: ASAPP.styles.textStyles.body2, colors: ASAPP.styles.colors.textButtonPrimary)
        }
        dismissButton.updateText(ASAPP.strings.notificationBannerDismissButton, textStyle: ASAPP.styles.textStyles.body2, colors: ASAPP.styles.colors.textButtonPrimary)
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
        expandIcon.frame = CGRect(x: bannerContainer.frame.width - contentInsets.right - expandIconSize.width + 5, y: ceil((bannerContainer.frame.height / 2) - (expandIconSize.height / 2)) + 1, width: expandIconSize.width, height: expandIconSize.height)
        
        titleLabel.frame = CGRect(x: titleLabelLeft, y: contentInsets.top, width: bannerContainer.frame.width - expandIcon.frame.width - contentInsets.right - contentInsets.left, height: availableHeight)
        
        // expanded container
        
        separator.frame = CGRect(x: contentInsets.left, y: 0, width: bounds.width - contentInsets.horizontal, height: 1)
        
        let bodyLabelSize = bodyLabel.sizeThatFits(CGSize(width: bounds.width - contentInsets.horizontal - 16, height: 0))
        bodyLabel.frame = CGRect(x: contentInsets.left + 8, y: 26, width: bodyLabelSize.width, height: bodyLabelSize.height)
        
        let buttonPadding: CGFloat = bodyLabel.superview != nil ? 24 : 0
        let buttonTop = bodyLabel.frame.maxY + buttonPadding
        let actionButtonSize = actionButton.superview == nil ? .zero : actionButton.sizeThatFits(CGSize(width: bounds.width - contentInsets.horizontal, height: .greatestFiniteMagnitude))
        let actionButtonWidth = actionButton.titleLabel?.text?.isEmpty ?? true ? 0 : actionButtonSize.width
        actionButton.frame = CGRect(x: expandedContainer.frame.maxX - contentInsets.right - actionButtonSize.width + textButtonInsets.right, y: buttonTop, width: actionButtonWidth, height: actionButtonSize.height)
        
        let buttonSpace: CGFloat = actionButtonWidth == 0 ? 0 : 22 - textButtonInsets.horizontal
        let buttonSeparatorHeight: CGFloat = 20
        let buttonSeparatorWidth: CGFloat = buttonSpace == 0 ? 0 : 1
        buttonSeparator.frame = CGRect(x: actionButton.frame.minX - (buttonSpace / 2), y: buttonTop + ((actionButton.frame.height / 2) - (buttonSeparatorHeight / 2)), width: buttonSeparatorWidth, height: buttonSeparatorHeight)
        
        let dismissButtonSize = dismissButton.sizeThatFits(CGSize(width: bounds.width - contentInsets.horizontal - actionButtonSize.width - buttonSpace, height: .greatestFiniteMagnitude))
        let dismissButtonLeft = buttonSeparator.frame.minX - dismissButtonSize.width - (buttonSpace / 2)
        dismissButton.frame = CGRect(x: dismissButtonLeft, y: buttonTop, width: dismissButtonSize.width, height: dismissButtonSize.height)
        
        let expandedHeight = calculateExpandedContainerHeight()
        expandedContainer.frame = CGRect(x: 0, y: bannerContainer.frame.maxY - (isExpanded ? 0 : expandedHeight), width: bounds.width, height: expandedHeight)
        
        bannerContainer.alpha = shouldHide ? 0 : 1
        expandedContainer.isHidden = shouldHide
        
        var elements: [Any] = [titleLabel]
        
        if overlayButton.superview != nil {
            let expandElement = UIAccessibilityElement(accessibilityContainer: self)
            expandElement.accessibilityLabel = ASAPPLocalizedString(isExpanded ? "Collapse" : "Expand")
            expandElement.accessibilityFrame = UIAccessibilityConvertFrameToScreenCoordinates(expandIcon.frame, bannerContainer)
            expandElement.accessibilityTraits = UIAccessibilityTraitButton
            elements.append(expandElement)
        }
        
        if isExpanded {
            elements.append(bodyLabel)
            elements.append(dismissButton)
            
            if actionButton.superview != nil {
                elements.append(actionButton)
            }
        }
        
        accessibilityElements = elements
    }
    
    private func calculateExpandedContainerHeight() -> CGFloat {
        let hasBodyLabel = bodyLabel.superview != nil
        let bodyLabelHeight = hasBodyLabel ? bodyLabel.sizeThatFits(CGSize(width: bounds.width - contentInsets.left - contentInsets.right - 16, height: 0)).height : 0
        let buttonHeight = (hasBodyLabel ? 24 : 0) + dismissButton.sizeThatFits(CGSize(width: bounds.width - contentInsets.horizontal, height: 0)).height
        return 26 + bodyLabelHeight + buttonHeight + 11
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
    
    func expand() {
        isExpanded = true
        updateExpandIcon()
    }
    
    @objc func didTapExpand() {
        expand()
        delegate?.notificationBannerDidTapExpand(self)
    }
    
    @objc func didTapCollapse() {
        isExpanded = false
        updateExpandIcon()
        delegate?.notificationBannerDidTapCollapse(self)
    }
    
    @objc func didTapDismissButton() {
        guard let button = notification.button else {
            return
        }
        delegate?.notificationBannerDidTapDismiss(self, button: button)
    }
    
    @objc func didTapActionButton() {
        guard let button = notification.button else {
            return
        }
        delegate?.notificationBannerDidTapActionButton(self, button: button)
    }
    
    func preferredDisplayHeight() -> CGFloat {
        return bannerContainerHeight + (isExpanded ? calculateExpandedContainerHeight() : 0)
    }
}
