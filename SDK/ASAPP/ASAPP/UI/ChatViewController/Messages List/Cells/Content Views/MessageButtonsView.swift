//
//  MessageButtonsView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 3/15/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

protocol MessageButtonsViewDelegate: class {
    func messageButtonsView(_ messageButtonsView: MessageButtonsView, didTapButtonWith action: Action)
}

class MessageButtonsView: UIView {
    weak var delegate: MessageButtonsViewDelegate?
    
    var contentInsets: UIEdgeInsets = .zero {
        didSet {
            updateButtonInsets()
        }
    }
    
    var buttons: [UIButton] = []
    var separators: [UIView] = []
    var actions: [Action] = []
    
    var separatorColor: UIColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
    let separatorHeight: CGFloat = 1
    
    private var messageActions: [QuickReply]
    
    init(messageActions: [QuickReply], separatorColor: UIColor? = nil) {
        self.messageActions = messageActions
        super.init(frame: .zero)
        
        if let separatorColor = separatorColor {
            self.separatorColor = separatorColor
        }
        
        backgroundColor = ASAPP.styles.colors.messageButtonBackground
        
        updateViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateViews() {
        subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        buttons = []
        separators = []
        actions = []
        
        for (i, messageAction) in messageActions.enumerated() {
            let button = createButton(for: messageAction)
            button.tag = i
            buttons.append(button)
            addSubview(button)
            actions.append(messageAction.action)
        }
        
        for _ in 0...buttons.count {
            let separator = createSeparator()
            separators.append(separator)
            addSubview(separator)
        }
    }
    
    private func createButton(for messageAction: QuickReply) -> UIButton {
        let button = UIButton()
        button.titleLabel?.numberOfLines = 0
        button.updateText(messageAction.title, textStyle: ASAPP.styles.textStyles.body, colors: ASAPP.styles.colors.textButtonPrimary)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        return button
    }
    
    private func createSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = separatorColor
        return view
    }
    
    private func updateButtonInsets() {
        buttons.forEach { button in
            button.titleEdgeInsets = UIEdgeInsets(top: 15, left: contentInsets.left, bottom: 18, right: contentInsets.right)
        }
    }
    
    @objc func didTapButton(_ sender: UIButton) {
        let action = actions[sender.tag]
        delegate?.messageButtonsView(self, didTapButtonWith: action)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonWidth = bounds.width
        let separatorInset: CGFloat = 9
        let separatorWidth = bounds.width - 2 * separatorInset
        
        var currentY: CGFloat = 0
        for (i, button) in buttons.enumerated() {
            separators[i].frame = CGRect(
                x: (i == 0 ? 0 : separatorInset) + 1,
                y: currentY,
                width: (i == 0 ? bounds.width : separatorWidth) - 2,
                height: separatorHeight)
            currentY += separatorHeight
            
            let buttonSize = button.sizeThatFits(CGSize(width: buttonWidth, height: .greatestFiniteMagnitude))
            button.frame = CGRect(x: 0, y: currentY, width: buttonWidth, height: buttonSize.height + button.titleEdgeInsets.top + button.titleEdgeInsets.bottom)
            currentY += button.frame.height
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var currentY: CGFloat = 0
        for button in buttons {
            currentY += separatorHeight
            
            let buttonSize = button.sizeThatFits(CGSize(width: size.width, height: .greatestFiniteMagnitude))
            currentY += buttonSize.height + button.titleEdgeInsets.top + button.titleEdgeInsets.bottom
        }
        return CGSize(width: size.width, height: floor(currentY))
    }
}
