//
//  SingleMessageViewController.swift
//  Tests
//
//  Created by Hans Hyttinen on 6/18/18.
//  Copyright © 2018 ASAPP. All rights reserved.
//

import UIKit
@testable import ASAPP

class SingleMessageViewController: UIViewController {
    let messagesView = ChatMessagesView(frame: .zero)
    var nextEventId: Int = 0
    var nextEventTime: TimeInterval = 327511937
    
    func createMessageEvent(fileName: String, isReply: Bool = true, time: TimeInterval? = nil) -> Event {
        let eventTime: TimeInterval
        if let time = time {
            eventTime = time
            nextEventTime = time + 10
        } else {
            eventTime = nextEventTime
            nextEventTime += 10
        }
        
        let eventId = nextEventId
        nextEventId += 1
        
        let dict = TestUtil.dictForFile(named: fileName)
        
        let event = Event(
            eventId: eventId,
            parentEventLogSeq: nil,
            eventType: .textMessage,
            ephemeralType: .none,
            eventTime: eventTime,
            issueId: 0,
            companyId: 0,
            customerId: 0,
            repId: 0,
            eventFlags: isReply ? 0 : 1,
            eventJSON: dict)
        
        let metadata = EventMetadata(
            isReply: isReply,
            isAutomatedMessage: false,
            eventId: eventId,
            eventType: .textMessage,
            issueId: 0,
            sendTime: Date(timeIntervalSince1970: eventTime))
        
        event.chatMessage = ChatMessage.fromJSON(dict, with: metadata)
        
        return event
    }
    
    func showMessage(fileName: String) {
        let event = createMessageEvent(fileName: fileName)
        messagesView.reloadWithEvents([event])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setLinearGradient(degrees: 161, colors: ASAPP.styles.colors.messagesListGradientColors)
        view.addSubview(messagesView)
        messagesView.frame = view.bounds
        messagesView.delegate = self
    }
}

extension SingleMessageViewController: ChatMessagesViewDelegate {
    func chatMessagesView(_ messagesView: ChatMessagesView, didTapImageView imageView: UIImageView, from message: ChatMessage) {}
    
    func chatMessagesViewPerformedKeyboardHidingAction(_ messagesView: ChatMessagesView) {}
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didUpdateQuickRepliesFrom message: ChatMessage) {}
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didTap buttonItem: ButtonItem, from message: ChatMessage) {}
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didTap button: QuickReply) {}
    
    func chatMessagesViewDidScrollNearBeginning(_ messagesView: ChatMessagesView) {}
    
    func chatMessagesViewShouldChangeAccessibilityFocus(_ messagesView: ChatMessagesView) -> Bool {
        return true
    }
}
