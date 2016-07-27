//
//  ChatMessagesView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesView: UIView {

    // MARK:- Public Properties
    
    private(set) var messageEvents: [Event] = []
    
    var contentInset: UIEdgeInsets {
        set { tableView.contentInset = newValue }
        get { return tableView.contentInset }
    }
    
    // MARK: Private Properties
    
    private var filteredMessageEvents: [Event] = []
    
    private let tableView = UITableView()

    private var eventsThatShouldAnimate = Set<Event>()
    
    private let MessageCellReuseId = "MessageCellReuseId"
    
    // MARK:- Initialization
    
    override init(frame: CGRect) {
        super.init(frame: CGRectZero)
     
        backgroundColor = UIColor.whiteColor()
        clipsToBounds = false
        
        tableView.frame = bounds
        tableView.clipsToBounds = false
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(ChatMessageEventCell.self, forCellReuseIdentifier: MessageCellReuseId)
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
}

// MARK:- UITableViewDataSource

extension ChatMessagesView: UITableViewDataSource {
    
    // Private Utilities
    
    private func messageEventForIndexPath(indexPath: NSIndexPath) -> Event? {
        if indexPath.row >= 0 && indexPath.row < filteredMessageEvents.count {
            return filteredMessageEvents[indexPath.row]
        }
        return nil
    }
    
    private func indexPathForMessageEvent(messageEvent: Event?) -> NSIndexPath? {
        guard let messageEvent = messageEvent else {
            return nil
        }
        
        var messageEventIndex: Int? = nil
        for (index, event) in filteredMessageEvents.enumerate() {
            if event.eventLogSeq == messageEvent.eventLogSeq {
                messageEventIndex = index
                break
            }
        }
        
        if let index = messageEventIndex {
            return NSIndexPath(forRow: index, inSection: 0)
        }
        return nil
    }
    
    private func messageBubbleStylingForIndexPath(indexPath: NSIndexPath) -> MessageBubbleStyling {
        guard let messageEvent = messageEventForIndexPath(indexPath) else { return .Default }
 
        let previousIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
        let nextIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
        
        let messageIsReply = messageEventIsReply(messageEvent)
        let previousIsReply = messageEventIsReply(messageEventForIndexPath(previousIndexPath))
        let nextIsReply = messageEventIsReply(messageEventForIndexPath(nextIndexPath))
        
        if messageIsReply == previousIsReply && messageIsReply == nextIsReply {
            return .MiddleOfMany
        }
        if messageIsReply == nextIsReply {
            return .FirstOfMany
        }
        if messageIsReply == previousIsReply {
            return .LastOfMany
        }
        
        return .Default
    }
    
    private func messageEventIsReply(messageEvent: Event?) -> Bool? {
        if let messageEvent = messageEvent {
            return messageEvent.isCustomerEvent
        }
        return nil
    }
    
    // UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMessageEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(MessageCellReuseId) as? ChatMessageEventCell {
            cell.messageEvent = messageEventForIndexPath(indexPath)
            cell.bubbleStyling = messageBubbleStylingForIndexPath(indexPath)
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK:- UITableViewDelegate

extension ChatMessagesView: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let event = messageEventForIndexPath(indexPath) else {
            return
        }

        if eventsThatShouldAnimate.contains(event) {
            (cell as? ChatMessageEventCell)?.animate()
            eventsThatShouldAnimate.remove(event)
        }
    }
}

// MARK:- Public Instance Methods

extension ChatMessagesView {
    
    func canDisplayMessageEvent(messageEvent: Event) -> Bool {
        return messageEvent.eventType == .TextMessage
    }
    
    func arraysOfMessageEventsAreDifferent(array1: [Event], array2: [Event]) -> Bool {
        guard array1.count == array2.count else {
            return true
        }
        
        for idx in 0..<array1.count {
            if array1[idx].eventLogSeq != array2[idx].eventLogSeq {
                return true
            }
        }
        
        return false
    }
    
    // MARK: Messages

    func replaceMessageEventsWithEvents(newMessageEvents: [Event]) {
        messageEvents = newMessageEvents
        filteredMessageEvents = messageEvents.filter({ (messageEvent: Event) -> Bool in
            return canDisplayMessageEvent(messageEvent)
        })
        tableView.reloadData()
    }
    
    func mergeMessageEventsWithEvents(newMessageEvents: [Event]) {
        guard messageEvents.count > 0 else {
            replaceMessageEventsWithEvents(newMessageEvents)
            return
        }
        
        var lastVisibleMessageEvent: Event?
        if let lastVisibleCell = tableView.visibleCells.last as? ChatMessageEventCell {
            lastVisibleMessageEvent = lastVisibleCell.messageEvent
        }
        
        var allMessages = [Event]()
        
        var setOfMessageEventLogSeqs = Set<Int>()
        func addOrSkipMessageEvent(event: Event) {
            if !setOfMessageEventLogSeqs.contains(event.eventLogSeq) {
                allMessages.append(event)
                setOfMessageEventLogSeqs.insert(event.eventLogSeq)
            }
        }
        
        // Favor newMessageEvents over old
        for event in newMessageEvents { addOrSkipMessageEvent(event) }
        for event in messageEvents { addOrSkipMessageEvent(event) }
        
        
        let mergedMessageEvents = allMessages.sort({ (event1, event2) -> Bool in
            return event1.eventLogSeq < event2.eventLogSeq
        })
        
        // Do not reload the view if the events are the same
        if arraysOfMessageEventsAreDifferent(mergedMessageEvents, array2: messageEvents) {
            messageEvents = mergedMessageEvents
            filteredMessageEvents = messageEvents.filter({ (messageEvent: Event) -> Bool in
                return canDisplayMessageEvent(messageEvent)
            })
            tableView.reloadData()
            
            if let lastVisibleIndexPath = indexPathForMessageEvent(lastVisibleMessageEvent) {
                tableView.scrollToRowAtIndexPath(lastVisibleIndexPath, atScrollPosition: .Bottom, animated: false)
            }
        }
    }
    
    func insertNewMessageEvent(event: Event) {
        let wasNearBottom = isNearBottom()
        
        messageEvents.append(event)
        if canDisplayMessageEvent(event) {
            filteredMessageEvents.append(event)
            // Only animate the message if the user is near the bottom
            if wasNearBottom {
                eventsThatShouldAnimate.insert(event)
            }
            UIView.performWithoutAnimation({ 
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            })
        }
        
        if wasNearBottom {
            scrollToBottomAnimated(true)
        }
    }
    
    // MARK: Scroll
    
    func isNearBottom(delta: CGFloat = 80) -> Bool {
        return tableView.contentOffset.y + delta >= tableView.contentSize.height - CGRectGetHeight(tableView.bounds)
    }
    
    func scrollToBottomIfNeeded(animated: Bool) {
        if !isNearBottom(10) {
            return
        }
        scrollToBottomAnimated(animated)
    }

    func scrollToBottomAnimated(animated: Bool) {
        var indexPath: NSIndexPath?
        let lastSection = numberOfSectionsInTableView(tableView) - 1
        if lastSection >= 0 {
            let lastRow = tableView(tableView, numberOfRowsInSection: lastSection) - 1
            if lastRow >= 0 {
                indexPath = NSIndexPath(forRow: lastRow, inSection: lastSection)
            }
        }
        
        if let indexPath = indexPath {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: animated)
        }
    }
}
