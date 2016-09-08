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
    func chatMessagesView(messagesView: ChatMessagesView, didSelectButtonItem buttonItem: SRSButtonItem)
    func chatMessagesViewPerformedKeyboardHidingAction(messagesView: ChatMessagesView)
}

class ChatMessagesView: UIView, ASAPPStyleable {
    
    // MARK:- Public Properties
    
    private(set) var credentials: Credentials
    
    var contentInsetTop: CGFloat = 0 {
        didSet {
            var newContentInset = defaultContentInset
            newContentInset.top += max(0, contentInsetTop)
            contentInset = newContentInset
            tableView.scrollIndicatorInsets = UIEdgeInsetsMake(contentInsetTop, 0, 0, 0)
        }
    }
    
    var delegate: ChatMessagesViewDelegate?
    
    var showTimeStampForEvent: Event?
    
    var earliestEvent: Event? {
        return dataSource.allEvents.first
    }
    
    var mostRecentEvent: Event? {
        return dataSource.allEvents.last
    }
    
    var isEmpty: Bool {
        return dataSource.isEmpty()
    }
    
    // MARK:- Private Properties
    
    private let cellAnimationsEnabled = true
    
    private var shouldShowTypingPreview: Bool {
//        return false
        return !credentials.isCustomer && otherParticipantTypingPreview != nil
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
    
    private let cellMaster: ChatMessagesViewCellMaster
    
    private let infoMessageView = ChatInfoMessageView()
    
    private var eventsThatShouldAnimate = Set<Event>()
    
    private var previousScrollOffsetY: CGFloat = 0.0
    private var maxScrollOffsetY: CGFloat = 0.0
    
    // MARK:- Initialization
    
    required init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        var allowedEventTypes: Set<EventType>
        if self.credentials.isCustomer {
            allowedEventTypes = [.TextMessage, .PictureMessage, .SRSResponse]
        } else {
            allowedEventTypes = [.TextMessage, .PictureMessage, .SRSResponse, .NewIssue, .NewRep, .CRMCustomerLinked]
        }
        self.dataSource = ChatMessagesViewDataSource(withAllowedEventTypes: allowedEventTypes)
        self.cellMaster = ChatMessagesViewCellMaster(withTableView: tableView)
        
        super.init(frame: CGRectZero)
        
        backgroundColor = UIColor.whiteColor()
        clipsToBounds = false
        
        tableView.frame = bounds
        tableView.contentInset = defaultContentInset
        tableView.clipsToBounds = false
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
        
        infoMessageView.frame = bounds
        infoMessageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        infoMessageView.title = ASAPPLocalizedString("Hi there, how can we help you?")
        infoMessageView.message = ASAPPLocalizedString("You can begin this conversation by writing a message below.")
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
    
    private(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        cellMaster.applyStyles(styles)
        
        backgroundColor = styles.backgroundColor1
        tableView.backgroundColor = styles.backgroundColor1
        tableView.reloadData()
        
        infoMessageView.applyStyles(styles)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.frame = bounds
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
    
    private func messageListPositionForIndexPath(indexPath: NSIndexPath) -> MessageListPosition {
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
  
        return cellMaster.timeStampHeaderView(withTimeStamp: dataSource.timeStampInSecondsForSection(section))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let event = dataSource.eventForIndexPath(indexPath) else {
            var typingCell: UITableViewCell?
            if shouldShowTypingPreview {
                typingCell = cellMaster.typingPreviewCell(forIndexPath: indexPath, withText: otherParticipantTypingPreview)
            } else {
                typingCell = cellMaster.typingIndicatorCell(forIndexPath: indexPath)
            }
            return typingCell ?? UITableViewCell()
        }
        
        let isReply = messageEventIsReply(event)
        let listPosition = messageListPositionForIndexPath(indexPath)
        let cell = cellMaster.cellForEvent(event,
                                           isReply: isReply ?? true,
                                           listPosition: listPosition,
                                           detailsVisible: event == showTimeStampForEvent,
                                           atIndexPath: indexPath)
        
        if let srsItemViewCell = cell as? ChatSRSItemListViewCell {
            srsItemViewCell.itemListView.delegate = self
        }
        
        return cell ?? UITableViewCell()
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
        
        if cellAnimationsEnabled && eventsThatShouldAnimate.contains(event) {
            (cell as? ChatTextMessageCell)?.animate()
            eventsThatShouldAnimate.remove(event)
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? ChatTypingIndicatorCell {
            cell.loadingView.endAnimating()
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         guard section < dataSource.numberOfSections() else { return 0.0 }
        
        return cellMaster.heightForTimeStampHeaderView(withTimeStamp: dataSource.timeStampInSecondsForSection(section))
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let event = dataSource.eventForIndexPath(indexPath) else {
            if shouldShowTypingPreview {
                return cellMaster.heightForTypingPreviewCell(withText: otherParticipantTypingPreview)
            }
            return cellMaster.heightForTypingIndicatorCell()
        }
        
        let isReply = messageEventIsReply(event)
        let listPosition = messageListPositionForIndexPath(indexPath)
        let height = cellMaster.heightForCellWithEvent(event,
                                                       isReply: isReply ?? true,
                                                       listPosition: listPosition,
                                                       detailsVisible: event == showTimeStampForEvent)
        return height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        endEditing(true)
        delegate?.chatMessagesViewPerformedKeyboardHidingAction(self)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let pictureCell = cell as? ChatPictureMessageCell,
            let event = pictureCell.event {
                delegate?.chatMessagesView(self, didTapImageView: pictureCell.pictureImageView, forEvent: event)
        } else if let bubbleCell = cell as? ChatBubbleCell {
            toggleTimeStampForEventAtIndexPath(indexPath)
        }
    }
    
    func toggleTimeStampForEventAtIndexPath(indexPath: NSIndexPath) {
        
        var previousEvent = showTimeStampForEvent
        
        // Hide timestamp on previous cell
        if let previousEvent = showTimeStampForEvent,
            let previousIndexPath = dataSource.indexPathOfEvent(previousEvent),
            let previousCell = tableView.cellForRowAtIndexPath(previousIndexPath) as? ChatBubbleCell {
            showTimeStampForEvent = nil
            previousCell.setDetailLabelHidden(true, animated: true)
        }

        if let nextEvent = dataSource.eventForIndexPath(indexPath) {
            // Show timestamp on next cell
            if previousEvent == nil || nextEvent != previousEvent {
                if let nextCell = tableView.cellForRowAtIndexPath(indexPath) as? ChatBubbleCell {
                    showTimeStampForEvent = nextEvent
                    nextCell.setDetailLabelHidden(false, animated: true)
                }
            }
        }
        
        // Update cell heights
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK:- SRSItemListViewDelegate

extension ChatMessagesView: SRSItemListViewDelegate {
    func itemListView(itemListView: SRSItemListView, didSelectButtonItem buttonItem: SRSButtonItem) {
        delegate?.chatMessagesView(self, didSelectButtonItem: buttonItem)
    }
}

// MARK:- Scroll

extension ChatMessagesView {
    
    func isNearBottom(delta: CGFloat = 80) -> Bool {
        let offsetWithDelta = tableView.contentOffset.y + delta
        let offsetAtBottom = tableView.contentSize.height - CGRectGetHeight(tableView.bounds)
        if offsetWithDelta >= offsetAtBottom {
            return true
        }
        
        return false
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
    
    func insertNewMessageEvent(event: Event, completion: (() -> Void)? = nil) {
        let wasNearBottom = isNearBottom()
        
        let indexPath = dataSource.addEvent(event)
        
        // Only animate the message if the user is near the bottom
        if cellAnimationsEnabled && wasNearBottom {
            eventsThatShouldAnimate.insert(event)
        }
        
        if let indexPath = indexPath {
            var previousIndexPath: NSIndexPath?
            if indexPath.row > 0 {
                previousIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
            }
            
            UIView.performWithoutAnimation({ 
                self.tableView.beginUpdates()
                if let previousIndexPath = previousIndexPath {
                    self.tableView.reloadRowsAtIndexPaths([previousIndexPath], withRowAnimation: .None)
                }
                if self.tableView.numberOfSections <= indexPath.section {
                    self.tableView.insertSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
                } else {
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
                self.tableView.endUpdates()
            })
        }
        
        if wasNearBottom {
            scrollToBottomAnimated(cellAnimationsEnabled)
        }
        
        updateSubviewVisibility()
        
        completion?()
    }
}
