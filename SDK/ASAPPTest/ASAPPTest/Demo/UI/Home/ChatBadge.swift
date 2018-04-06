//
//  ChatBadge.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 4/4/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class ChatBadge: UIView {
    enum State {
        case live(Int)
        case unread(Int)
        case none
    }
    
    private var state: State = .none
    
    private let bubble = UIView()
    private let label = UILabel()
    
    func commonInit() {
        bubble.layer.borderWidth = 0.5
        bubble.layer.borderColor = UIColor.white.cgColor
        addSubview(bubble)
        
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = DemoFonts.asapp.medium.withSize(10)
        label.textColor = .white
        bubble.addSubview(label)
        
        updateDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func update(unread: Int, isLiveChat: Bool) {
        if isLiveChat {
            state = .live(unread)
        } else {
            if unread > 0 {
                state = .unread(unread)
            } else {
                state = .none
            }
        }
        
        updateDisplay()
    }
    
    func updateDisplay() {
        let visible: Bool
        let num: Int?
        let color: UIColor
        
        switch state {
        case let .unread(unread):
            visible = true
            num = unread
            color = UIColor(red: 0.96, green: 0.2, blue: 0.38, alpha: 1)
        case let .live(unread):
            visible = true
            num = unread > 0 ? unread : nil
            color = UIColor(red: 0.11, green: 0.68, blue: 0.52, alpha: 1)
        case .none:
            visible = false
            num = 0
            color = .clear
        }
        
        bubble.alpha = visible ? 1 : 0
        label.alpha = bubble.alpha
        label.text = num != nil ? String(num ?? 0) : ""
        bubble.backgroundColor = color
        setNeedsLayout()
    }
    
    private struct CalculatedLayout {
        let bubbleFrame: CGRect
        let labelFrame: CGRect
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        let labelSize = label.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: bounds.height))
        let bubbleFrame = CGRect(x: 0, y: 0, width: max(bounds.height, labelSize.width + 12), height: bounds.height)
        let labelFrame = bubbleFrame
        return CalculatedLayout(bubbleFrame: bubbleFrame, labelFrame: labelFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getFramesThatFit(bounds.size)
        bubble.frame = layout.bubbleFrame
        label.frame = layout.labelFrame
        bubble.layer.cornerRadius = bubble.frame.height / 2
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getFramesThatFit(size)
        return layout.bubbleFrame.size
    }
}
