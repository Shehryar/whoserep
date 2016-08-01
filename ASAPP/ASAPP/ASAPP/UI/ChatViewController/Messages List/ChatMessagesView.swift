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
    
    
    
    // MARK:- Private Properties
    
    private var otherParticipantIsTyping: Bool = false
    
    private var otherParticipantTypingPreview: String?
    
    private var contentInset: UIEdgeInsets {
        set { tableView.contentInset = newValue }
        get { return tableView.contentInset }
    }
    
    private let defaultContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    
    private var dataSource = ChatMessagesViewDataSource()
    
    private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    private var eventsThatShouldAnimate = Set<Event>()
    
    private let HeaderViewReuseId = "TimeStampHeaderReuseId"
    private let MessageCellReuseId = "MessageCellReuseId"
    private let TypingPreviewCellReuseId = "TypingPreviewCellReuseId"
    private let TypingStatusCellReuseId = "TypingStatusCellReuseId"
    
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
        tableView.estimatedSectionHeaderHeight = 30
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))
        tableView.registerClass(ChatMessageEventCell.self, forCellReuseIdentifier: MessageCellReuseId)
        tableView.registerClass(ChatTypingIndicatorCell.self, forCellReuseIdentifier: TypingStatusCellReuseId)
        tableView.registerClass(ChatTypingPreviewCell.self, forCellReuseIdentifier: TypingPreviewCellReuseId)
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = dataSource.numberOfSections()
        if otherParticipantIsTyping {
            return max(1, numberOfSections)
        } else {
            return numberOfSections
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let lastSection = dataSource.numberOfSections() - 1
        if section == lastSection && otherParticipantIsTyping {
            return dataSource.numberOfRowsInSection(section) + 1
        }
        return dataSource.numberOfRowsInSection(section)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < dataSource.numberOfSections() else { return nil }
        
        var headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderViewReuseId) as? ChatMessagesTimeHeaderView
        if headerView == nil {
            headerView = ChatMessagesTimeHeaderView(reuseIdentifier: HeaderViewReuseId)
        }
        
        headerView?.timeStampInSeconds = dataSource.timeStampInSecondsForSection(section)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let event = dataSource.eventForIndexPath(indexPath)
        
        // Typing-Cell
        if event == nil {
            if !credentials.isCustomer && otherParticipantTypingPreview != nil {
                if let cell = tableView.dequeueReusableCellWithIdentifier(TypingPreviewCellReuseId) as? ChatTypingPreviewCell {
                    cell.previewText = otherParticipantTypingPreview
                    return cell
                }
            } else if let cell = tableView.dequeueReusableCellWithIdentifier(TypingStatusCellReuseId) as? ChatTypingIndicatorCell {
                cell.isReply = true
                cell.bubbleStyling = .Default
                return cell
            }
            return UITableViewCell()
        }
        
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
        if let isTypingCell = cell as? ChatTypingIndicatorCell {
            if !isTypingCell.loadingView.animating {
                isTypingCell.loadingView.beginAnimating()
            }
            return
        }
        
        guard let event = dataSource.eventForIndexPath(indexPath) else {
            return
        }
        
        if eventsThatShouldAnimate.contains(event) {
            (cell as? ChatMessageEventCell)?.animate()
            eventsThatShouldAnimate.remove(event)
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? ChatTypingIndicatorCell {
            cell.loadingView.endAnimating()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        endEditing(true)
    }
}

// MARK:- Scroll

extension ChatMessagesView {
    
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

// MARK:- Typing Status / Preview

extension ChatMessagesView {
    
    func updateOtherParticipantTypingStatus(isTyping: Bool, withPreviewText previewText: String?) {
        var isDifferent = isTyping != otherParticipantIsTyping
        if !credentials.isCustomer {
            isDifferent = isDifferent || previewText != otherParticipantTypingPreview
        }
        let shouldScrollToBottom = isNearBottom() && isDifferent
        
        otherParticipantIsTyping = isTyping
        otherParticipantTypingPreview = previewText
        
        if isDifferent {
            tableView.reloadData()
        }
        
        if shouldScrollToBottom {
            scrollToBottomAnimated(false)
        }
    }
    
    func indexPathForTypingPreviewCell() -> NSIndexPath {
        let lastSection = dataSource.numberOfSections() - 1
        if lastSection < 0 {
            return NSIndexPath(forRow: 0, inSection: 0)
        } else {
            let lastRow = dataSource.numberOfRowsInSection(lastSection)
            return NSIndexPath(forRow: lastRow, inSection: lastSection)
        }
    }
}

// MARK:- Adding / Replacing Messages

extension ChatMessagesView {
    
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
}
