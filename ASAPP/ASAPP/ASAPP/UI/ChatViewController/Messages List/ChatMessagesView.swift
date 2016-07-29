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

    var credentials: Credentials
    
    var contentInsetTop: CGFloat = 0 {
        didSet {
            var newContentInset = defaultContentInset
            newContentInset.top += max(0, contentInsetTop)
            contentInset = newContentInset
        }
    }
    
    // MARK: Private Properties
    
    private var contentInset: UIEdgeInsets {
        set { tableView.contentInset = newValue }
        get { return tableView.contentInset }
    }
    
    private let defaultContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    
    private var dataSource = ChatMessagesViewDataSource()
    
    private let tableView = UITableView(frame: CGRectZero, style: .Grouped)

    private var eventsThatShouldAnimate = Set<Event>()
    
    private let MessageCellReuseId = "MessageCellReuseId"
    
    // MARK:- Initialization
    
    required init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        super.init(frame: CGRectZero)
        
        backgroundColor = UIColor.whiteColor()
        clipsToBounds = false
        
        tableView.frame = bounds
        tableView.contentInset = defaultContentInset
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
    
    private func messageBubbleStylingForIndexPath(indexPath: NSIndexPath) -> MessageBubbleStyling {
        guard let messageEvent = dataSource.eventForIndexPath(indexPath) else { return .Default }

        let messageIsReply = messageEventIsReply(messageEvent)
        let previousIsReply = messageEventIsReply(dataSource.getEvent(inSection: indexPath.section, row: indexPath.row - 1))
        let nextIsReply = messageEventIsReply(dataSource.getEvent(inSection: indexPath.section, row: indexPath.row + 1))
        
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
        guard let messageEvent = messageEvent else { return nil }
        
        return !messageEvent.wasSentByUserWithCredentials(credentials)
    }
    
    // UITableViewDataSource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let timeStamp = dataSource.timeStampForSection(section)
        guard timeStamp > 0 else {
            return nil
        }
        let date = NSDate(timeIntervalSince1970: timeStamp)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm zzz"
        
        return "Send Time: \(dateFormatter.stringFromDate(date))"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRowsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let event = dataSource.eventForIndexPath(indexPath)
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(MessageCellReuseId) as? ChatMessageEventCell {
            cell.messageEvent = event
            cell.isReply = messageEventIsReply(cell.messageEvent) ?? false
            cell.bubbleStyling = messageBubbleStylingForIndexPath(indexPath)
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK:- UITableViewDelegate

extension ChatMessagesView: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let event = dataSource.eventForIndexPath(indexPath) else {
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
        dataSource.reloadWithEvents(newMessageEvents)
        
        tableView.reloadData()
    }
    
    func mergeMessageEventsWithEvents(newMessageEvents: [Event]) {
        guard newMessageEvents.count > 0 else {
            return
        }
        
        let wasNearBottom = isNearBottom()
        var lastVisibleMessageEvent: Event?
        if let lastVisibleCell = tableView.visibleCells.last as? ChatMessageEventCell {
            lastVisibleMessageEvent = lastVisibleCell.messageEvent
        }
        
        dataSource.mergeWithEvents(newMessageEvents)
        
        tableView.reloadData()
        
        if wasNearBottom {
            scrollToBottomAnimated(false)
        } else if let lastVisibleIndexPath = dataSource.indexPathOfEvent(lastVisibleMessageEvent) {
            tableView.scrollToRowAtIndexPath(lastVisibleIndexPath, atScrollPosition: .Bottom, animated: false)
        }
    }
    
    func insertNewMessageEvent(event: Event) {
        let wasNearBottom = isNearBottom()
        
        dataSource.addEvent(event)
        
        // Only animate the message if the user is near the bottom
        if wasNearBottom {
            eventsThatShouldAnimate.insert(event)
        }
        
        UIView.performWithoutAnimation({
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        })
        
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
