//
//  BaseActionSheet.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 2/5/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

protocol ActionSheetDelegate: class {
    func actionSheetDidTapHide(_ actionSheet: BaseActionSheet)
    func actionSheetDidTapConfirm(_ actionSheet: BaseActionSheet)
    func actionSheetWillShow(_ actionSheet: BaseActionSheet)
}

class BaseActionSheet: UIView {
    weak var delegate: ActionSheetDelegate?
    
    let buttonAnimationDuration: TimeInterval = 0.26
    let contentView = UIView()
    
    private let blurredBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    let hideButton = UIButton()
    let confirmButton = UIButton()
    private var activityIndicator: UIActivityIndicatorView?
    
    private let sheetInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private let contentInsets = UIEdgeInsets(top: 43, left: 40, bottom: 48, right: 40)
    private let buttonInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
    
    private var buttonAnimating = false
    private var onButtonAnimationComplete: (() -> Void)?
    private var hiding = false
    
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
        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        confirmButton.updateText(restartButtonTitle, textStyle: ASAPP.styles.textStyles.actionButton, colors: actionColors)
        confirmButton.setTitleShadow(opacity: 0.18)
        confirmButton.contentEdgeInsets = buttonInsets
        confirmButton.clipsToBounds = true
        confirmButton.layer.shadowColor = UIColor.ASAPP.lakeMinnetonka.cgColor
        confirmButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        confirmButton.layer.shadowRadius = 20
        confirmButton.layer.shadowOpacity = 0.25
        contentView.addSubview(confirmButton)
        
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
    
    private struct CalculatedLayout {
        let blurredBackgroundFrame: CGRect
        let titleLabelFrame: CGRect
        let bodyLabelFrame: CGRect
        let confirmButtonFrame: CGRect
        let hideButtonFrame: CGRect
        let contentViewFrame: CGRect
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        let blurredBackgroundFrame = CGRect(origin: .zero, size: size)
        
        let contentWidth = size.width - sheetInsets.left - sheetInsets.right
        let contentFitSize = CGSize(width: contentWidth - contentInsets.left - contentInsets.right, height: 0)
        
        let titleLabelSize = hasTitleLabel ? titleLabel.sizeThatFits(contentFitSize) : .zero
        let titleLabelFrame = CGRect(x: round(contentWidth / 2 - titleLabelSize.width / 2), y: contentInsets.top, width: titleLabelSize.width, height: titleLabelSize.height)
        
        let bodyLabelSize = bodyLabel.sizeThatFits(contentFitSize)
        let bodyLabelFrame = CGRect(x: round(contentWidth / 2 - bodyLabelSize.width / 2), y: titleLabelFrame.maxY + bodyLabelPadding, width: bodyLabelSize.width, height: bodyLabelSize.height)
        
        let confirmButtonSize = confirmButton.sizeThatFits(contentFitSize)
        let confirmButtonFrame = CGRect(x: round(contentWidth / 2 - confirmButtonSize.width / 2), y: bodyLabelFrame.maxY + 36, width: confirmButtonSize.width, height: confirmButtonSize.height)
        
        let hideButtonSize = hideButton.sizeThatFits(contentFitSize)
        let hideButtonFrame = CGRect(x: round(contentWidth / 2 - hideButtonSize.width / 2), y: confirmButtonFrame.maxY + 10, width: hideButtonSize.width, height: hideButtonSize.height)
        
        let totalHeight = hideButtonFrame.maxY + contentInsets.bottom
        let contentViewFrame = CGRect(x: sheetInsets.left, y: size.height - totalHeight, width: contentWidth, height: totalHeight)
        
        return CalculatedLayout(
            blurredBackgroundFrame: blurredBackgroundFrame,
            titleLabelFrame: titleLabelFrame,
            bodyLabelFrame: bodyLabelFrame,
            confirmButtonFrame: confirmButtonFrame,
            hideButtonFrame: hideButtonFrame,
            contentViewFrame: contentViewFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    func updateFrames(in bounds: CGRect? = nil) {
        guard !hiding else {
            return
        }
        
        let bounds = bounds ?? self.bounds
        let layout = getFramesThatFit(bounds.size)
        
        blurredBackground.frame = layout.blurredBackgroundFrame
        titleLabel.frame = layout.titleLabelFrame
        bodyLabel.frame = layout.bodyLabelFrame
        confirmButton.frame = layout.confirmButtonFrame
        activityIndicator?.frame = layout.confirmButtonFrame
        hideButton.frame = layout.hideButtonFrame
        contentView.frame = layout.contentViewFrame
        
        confirmButton.layer.cornerRadius = layout.confirmButtonFrame.height / 2
        hideButton.layer.cornerRadius = layout.hideButtonFrame.height / 2
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchesOutOfSheet(touches) {
            delegate?.actionSheetDidTapHide(self)
        }
    }
 
    func touchesOutOfSheet(_ touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else { return false }
        
        let touchLocation = touch.location(in: self)
        let touchableArea = bounds.divided(atDistance: contentView.frame.height, from: .maxYEdge).remainder
        
        return touchableArea.contains(touchLocation)
    }
    
    @objc func didTapHideButton() {
        delegate?.actionSheetDidTapHide(self)
    }
    
    @objc func didTapConfirmButton() {
        delegate?.actionSheetDidTapConfirm(self)
    }
    
    func show(in parent: UIView, below other: UIView? = nil) {
        delegate?.actionSheetWillShow(self)
        
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
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.contentView.frame = contentViewFinalFrame
        }, completion: { [weak self] _ in
            self?.accessibilityViewIsModal = true
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self)
        })
    }
    
    func hide(_ completion: (() -> Void)? = nil) {
        hiding = true
        var contentViewFinalFrame = contentView.frame
        contentViewFinalFrame.origin.y = contentView.frame.maxY
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.contentView.frame = contentViewFinalFrame
        }, completion: { [weak self] _ in
            guard let superview = self?.superview else {
                return
            }
            self?.removeFromSuperview()
            self?.hiding = false
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, superview)
            completion?()
        })
    }
    
    func showSpinner() {
        confirmButton.isEnabled = false
        
        activityIndicator = UIActivityIndicatorView(frame: confirmButton.frame)
        if let spinner = activityIndicator {
            spinner.backgroundColor = .clear
            spinner.activityIndicatorViewStyle = .gray
            spinner.frame = confirmButton.frame
            contentView.insertSubview(spinner, belowSubview: confirmButton)
            spinner.startAnimating()
            spinner.alpha = 0
        }
        
        var finalButtonFrame = confirmButton.frame
        finalButtonFrame.size.width = confirmButton.frame.size.height
        finalButtonFrame.origin.x += (confirmButton.frame.size.width - finalButtonFrame.size.width) / 2
        
        let rotation = CGAffineTransform(rotationAngle: .pi / -2)
        buttonAnimating = true
        
        UIView.animate(withDuration: buttonAnimationDuration / 2, delay: 0, options: .curveEaseIn, animations: {[weak self] in
            guard let button = self?.confirmButton else { return }
            button.frame = finalButtonFrame
        }, completion: nil)
        
        UIView.animate(withDuration: buttonAnimationDuration, animations: { [weak self] in
            guard let button = self?.confirmButton else { return }
            self?.activityIndicator?.alpha = 1
            button.transform = rotation
            button.alpha = 0
        }, completion: { [weak self] _ in
            self?.buttonAnimating = false
            self?.onButtonAnimationComplete?()
        })
    }
    
    func hideSpinner() {
        func f() {
            activityIndicator?.removeFromSuperview()
            confirmButton.isEnabled = true
            confirmButton.titleLabel?.alpha = 1
            confirmButton.transform = .identity
            confirmButton.alpha = 1
            confirmButton.updateBackgroundColors(ASAPP.styles.colors.actionButton)
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        if buttonAnimating {
            onButtonAnimationComplete = f
        } else {
            f()
        }
    }
}
