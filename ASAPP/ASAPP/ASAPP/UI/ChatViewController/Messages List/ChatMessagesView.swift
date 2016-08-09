//
//  ChatMessagesView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatMessagesViewDelegate {
    func chatMessagesView(messagesView: ChatMessagesView, didTapImageView imageView: UIImageView, forEvent event: Event)
}

class ChatMessagesView: UIView, ASAPPStyleable {
    
    // MARK:- Public Properties
    
    private(set) var credentials: Credentials
    
    var contentInsetTop: CGFloat = 0 {
        didSet {
            var newContentInset = defaultContentInset
            newContentInset.top += max(0, contentInsetTop)
            contentInset = newContentInset
        }
    }
    
    var delegate: ChatMessagesViewDelegate?
    
    // MARK:- Private Properties
    
    private var shouldShowTypingPreview: Bool {
        return false
//        return !credentials.isCustomer && otherParticipantTypingPreview != nil
    }
    
    private var otherParticipantIsTyping: Bool = false
    
    private var otherParticipantTypingPreview: String?
    
    private var contentInset: UIEdgeInsets {
        set { tableView.contentInset = newValue }
        get { return tableView.contentInset }
    }
    
    private let defaultContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    
    private var dataSource: ChatMessagesViewDataSource
    
    private let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    private let infoMessageView = ChatInfoMessageView()
    
    private var eventsThatShouldAnimate = Set<Event>()
    
    private let HeaderViewReuseId = "TimeStampHeaderReuseId"
    private let TextMessageCellReuseId = "TextMessageCellReuseId"
    private let PictureMessageCellReuseId = "PictureMessageCellReuseId"
    private let TypingPreviewCellReuseId = "TypingPreviewCellReuseId"
    private let TypingStatusCellReuseId = "TypingStatusCellReuseId"
    private let InfoTextCellReuseId = "InfoTextCellReuseId"
    
    // MARK:- Initialization
    
    required init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        var allowedEventTypes: Set<EventType>
        if self.credentials.isCustomer {
            allowedEventTypes = [.TextMessage, .PictureMessage]
        } else {
            allowedEventTypes = [.TextMessage, .PictureMessage, .NewIssue, .NewRep, .CRMCustomerLinked]
        }
        self.dataSource = ChatMessagesViewDataSource(withAllowedEventTypes: allowedEventTypes)
        
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
        tableView.registerClass(ChatTextMessageCell.self, forCellReuseIdentifier: TextMessageCellReuseId)
        tableView.registerClass(ChatPictureMessageCell.self, forCellReuseIdentifier: PictureMessageCellReuseId)
        tableView.registerClass(ChatTypingIndicatorCell.self, forCellReuseIdentifier: TypingStatusCellReuseId)
        tableView.registerClass(ChatTypingPreviewCell.self, forCellReuseIdentifier: TypingPreviewCellReuseId)
        tableView.registerClass(ChatInfoTextCell.self, forCellReuseIdentifier: InfoTextCellReuseId)
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
        
        // TODO: Localization
        infoMessageView.frame = bounds
        infoMessageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        infoMessageView.title = "Hi there, how can we help you?"
        infoMessageView.message = "You can begin this conversation by writing a message below."
        addSubview(infoMessageView)
        
        updateSubviewVisibility()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK:- ASAPPStyleable
    
    var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        backgroundColor = styles.backgroundColor1
        tableView.backgroundColor = styles.backgroundColor1
        tableView.reloadData()
        
        infoMessageView.applyStyles(styles)
    }
}

// MARK:- Utility

extension ChatMessagesView {

    func updateSubviewVisibility() {
        if dataSource.isEmpty() {
            infoMessageView.hidden = false
        } else {
            infoMessageView.hidden = true
        }
    }
    
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
}


// MARK:- UITableViewDataSource

extension ChatMessagesView: UITableViewDataSource {
    
    // MARK: Number of Item
    
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
    
    // MARK: Views / Cells
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < dataSource.numberOfSections() else { return nil }
        
        var headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderViewReuseId) as? ChatMessagesTimeHeaderView
        if headerView == nil {
            headerView = ChatMessagesTimeHeaderView(reuseIdentifier: HeaderViewReuseId)
        }
        headerView?.applyStyles(styles)
        headerView?.timeStampInSeconds = dataSource.timeStampInSecondsForSection(section)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let event = dataSource.eventForIndexPath(indexPath) else {
            // Typing Preview
            if shouldShowTypingPreview {
                let cell = tableView.dequeueReusableCellWithIdentifier(TypingPreviewCellReuseId) as? ChatTypingPreviewCell
                cell?.messageText = otherParticipantTypingPreview
                cell?.applyStyles(styles, isReply: true)
                return cell ?? UITableViewCell()
            }
            
            // Typing Status
            let cell = tableView.dequeueReusableCellWithIdentifier(TypingStatusCellReuseId) as? ChatTypingIndicatorCell
            cell?.applyStyles(styles, isReply: true)
            cell?.bubbleStyling = .Default
            return cell ?? UITableViewCell()
        }
        
        // Picture Message
        if event.eventType == .PictureMessage {
            let cell = tableView.dequeueReusableCellWithIdentifier(PictureMessageCellReuseId) as? ChatPictureMessageCell
            cell?.applyStyles(styles, isReply: messageEventIsReply(event) ?? false)
            cell?.bubbleStyling = messageBubbleStylingForIndexPath(indexPath)
            cell?.event = event
            return cell ?? UITableViewCell()
            
        }
        
        // Text Message
        if event.eventType == .TextMessage {
            let cell = tableView.dequeueReusableCellWithIdentifier(TextMessageCellReuseId) as? ChatTextMessageCell
            cell?.applyStyles(styles, isReply: messageEventIsReply(event) ?? false)
            cell?.bubbleStyling = messageBubbleStylingForIndexPath(indexPath)
            cell?.messageText = event.textMessage?.text
            return cell ?? UITableViewCell()
        }
        
        // Info Cell
        if [EventType.CRMCustomerLinked, EventType.NewIssue, EventType.NewRep].contains(event.eventType) {
            let cell = tableView.dequeueReusableCellWithIdentifier(InfoTextCellReuseId) as? ChatInfoTextCell
            cell?.applyStyles(styles)
            
            switch event.eventType {
            case .CRMCustomerLinked:
                cell?.infoText = "Customer Linked"
                break
                
            case .NewIssue:
                cell?.infoText = "New Issue: \(event.newIssue?.issueId ?? 0)"
                break
                
            case .NewRep:
                cell?.infoText = "New Rep: \(event.newRep?.name ?? String(event.newRep?.repId))"
                break
                
            default:  // Other cases not handled
                break
            }
            
            return cell ?? UITableViewCell()
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
            (cell as? ChatTextMessageCell)?.animate()
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
        
        if let pictureCell = tableView.cellForRowAtIndexPath(indexPath) as? ChatPictureMessageCell,
            let event = pictureCell.event {
                delegate?.chatMessagesView(self, didTapImageView: pictureCell.pictureImageView, forEvent: event)
        }
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
        if shouldShowTypingPreview {
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
        
        updateSubviewVisibility()
    }
    
    func mergeMessageEventsWithEvents(newMessageEvents: [Event]) {
        guard newMessageEvents.count > 0 else {
            return
        }
        
        let wasNearBottom = isNearBottom()
        var lastVisibleMessageEvent: Event?
        if let lastVisibleCell = tableView.visibleCells.last as? ChatTextMessageCell {
            lastVisibleMessageEvent = lastVisibleCell.event
        }
        
        dataSource.mergeWithEvents(newMessageEvents)
        
        tableView.reloadData()
        
        if wasNearBottom {
            scrollToBottomAnimated(false)
        } else if let lastVisibleIndexPath = dataSource.indexPathOfEvent(lastVisibleMessageEvent) {
            tableView.scrollToRowAtIndexPath(lastVisibleIndexPath, atScrollPosition: .Bottom, animated: false)
        }
        
        updateSubviewVisibility()
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
        
        updateSubviewVisibility()
    }
}
