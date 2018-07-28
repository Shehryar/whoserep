//
//  MessageButtonsView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 3/15/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

protocol MessageButtonsViewDelegate: class {
    func messageButtonsView(_ messageButtonsView: MessageButtonsView, didTap button: QuickReply)
}

class MessageButtonsView: UIView {
    weak var delegate: MessageButtonsViewDelegate?
    
    var contentInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16) {
        didSet {
            updateButtonInsets()
        }
    }
    
    var buttons: [UIButton] = []
    var separators: [UIView] = []
    var actions: [Action] = []
    
    var separatorColor: UIColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
    let separatorHeight: CGFloat = 1
    
    private var messageButtons: [QuickReply]
    
    init(messageButtons: [QuickReply], separatorColor: UIColor? = nil) {
        self.messageButtons = messageButtons
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
        
        for (i, messageAction) in messageButtons.enumerated() {
            let button = createButton(for: messageAction)
            button.tag = i
            buttons.append(button)
            addSubview(button)
            actions.append(messageAction.action)
        }
        
        updateButtonInsets()
        
        for _ in 0...buttons.count {
            let separator = createSeparator()
            separators.append(separator)
            addSubview(separator)
        }
    }
    
    private func createButton(for messageAction: QuickReply) -> UIButton {
        let button = UIButton()
        button.updateText(messageAction.title, textStyle: ASAPP.styles.textStyles.body, colors: ASAPP.styles.colors.textButtonPrimary)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
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
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: contentInsets.left, bottom: 14, right: contentInsets.right)
        }
    }
    
    @objc func didTapButton(_ sender: UIButton) {
        let button = messageButtons[sender.tag]
        delegate?.messageButtonsView(self, didTap: button)
    }
    
    private struct CalculatedLayout {
        let buttonFrames: [CGRect]
        let separatorFrames: [CGRect]
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        var buttonFrames: [CGRect] = []
        var separatorFrames: [CGRect] = []
        
        let buttonWidth = size.width
        let separatorInset: CGFloat = 9
        let separatorWidth = size.width - 2 * separatorInset
        
        var currentY: CGFloat = 0
        for (i, button) in buttons.enumerated() {
            separatorFrames.append(CGRect(
                x: (i == 0 ? 0 : separatorInset) + 1,
                y: currentY,
                width: (i == 0 ? size.width : separatorWidth) - 2,
                height: separatorHeight))
            currentY += separatorHeight
            
            let maxLabelWidth: CGFloat = size.width - button.contentEdgeInsets.horizontal
            let labelSize = button.titleLabel?.sizeThatFits(CGSize(width: maxLabelWidth, height: .greatestFiniteMagnitude)) ?? .zero
            let buttonHeight = labelSize.height + button.contentEdgeInsets.vertical
            buttonFrames.append(CGRect(x: 0, y: currentY, width: buttonWidth, height: buttonHeight))
            currentY += buttonHeight
        }
        
        return CalculatedLayout(buttonFrames: buttonFrames, separatorFrames: separatorFrames)
    }
    
    func updateFrames() {
        let layout = getFramesThatFit(bounds.size)
        for (i, button) in buttons.enumerated() {
            button.frame = layout.buttonFrames[i]
            separators[i].frame = layout.separatorFrames[i]
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getFramesThatFit(size)
        let height = layout.buttonFrames.last?.maxY ?? 0
        return CGSize(width: size.width, height: ceil(height))
    }
}
