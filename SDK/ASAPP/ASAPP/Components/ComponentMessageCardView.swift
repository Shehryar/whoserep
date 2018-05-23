//
//  ComponentMessageCardView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/18/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class ComponentMessageCardView: ComponentCardView, MessageBubbleCornerRadiusUpdating {
    var message: ChatMessage? {
        didSet {
            updateRoundedCorners()
        }
    }
    
    var messagePosition: MessageListPosition = .none {
        didSet {
            updateRoundedCorners()
        }
    }
    
    override func updateRoundedCorners() {
        if let message = message {
            roundedCorners = getBubbleCorners(for: message, isAttachment: true)
        }
    }
}
