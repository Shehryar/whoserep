//
//  ChatMessagesView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatMessagesViewDelegate {
    func chatMessagesView(_ messagesView: ChatMessagesView, didTapImageView imageView: UIImageView, forEvent event: Event)
    func chatMessagesView(_ messagesView: ChatMessagesView, didSelectButtonItem buttonItem: SRSButtonItem)
    func chatMessagesView(_ messagesView: ChatMessagesView, didUpdateButtonItemsForEvent event: Event)
    func chatMessagesViewPerformedKeyboardHidingAction(_ messagesView: ChatMessagesView)
    func chatMessagesView(_ messagesView: ChatMessagesView, didTapMostRecentEvent event: Event)
}

class ChatMessagesView: UIView {
    
    // MARK:- Public Properties
    
    fileprivate(set) var credentials: Credentials
    
    fileprivate(set) var styles: ASAPPStyles
    
    fileprivate(set) var strings: ASAPPStrings
    
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
    
    var numberOfEvents: Int {
        return dataSource.allEvents.count
    }
    
    var mostRecentEvent: Event? {
        return dataSource.getLastEvent()
    }
    
    var isEmpty: Bool {
        return dataSource.isEmpty()
    }
    
    // MARK:- Private Properties
    
    fileprivate let cellAnimationsEnabled = true
    
    fileprivate var shouldShowTypingPreview: Bool {
//        return false
        return !credentials.isCustomer && otherParticipantTypingPreview != nil
    }
    
    fileprivate var otherParticipantIsTyping: Bool = false
    
    fileprivate var otherParticipantTypingPreview: String?
    
    fileprivate var contentInset: UIEdgeInsets {
        set { tableView.contentInset = newValue }
        get { return tableView.contentInset }
    }
    
    fileprivate let defaultContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
    
    fileprivate var dataSource: ChatMessagesViewDataSource
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    fileprivate let cellMaster: ChatMessagesViewCellMaster
    
    fileprivate let infoMessageView = ChatInfoMessageView()
    
    fileprivate var eventsThatShouldAnimate = Set<Event>()
    
    // MARK:- Initialization
    
    required init(withCredentials credentials: Credentials, styles: ASAPPStyles, strings: ASAPPStrings) {
        self.credentials = credentials
        self.styles = styles
        self.strings = strings
        
        var allowedEventTypes: Set<EventType>
        if self.credentials.isCustomer {
            allowedEventTypes = [.textMessage, .pictureMessage, .srsResponse]
        } else {
            allowedEventTypes = [.textMessage, .pictureMessage, .srsResponse, .newIssue, .newRep, .crmCustomerLinked]
        }
        self.dataSource = ChatMessagesViewDataSource(withAllowedEventTypes: allowedEventTypes)
        self.cellMaster = ChatMessagesViewCellMaster(withTableView: tableView, styles: styles)
        super.init(frame: CGRect.zero)
        
        backgroundColor = styles.backgroundColor1
        clipsToBounds = false
        
        tableView.frame = bounds
        tableView.contentInset = defaultContentInset
        tableView.clipsToBounds = false
        tableView.backgroundColor = styles.backgroundColor1
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
        
        infoMessageView.frame = bounds
        infoMessageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        infoMessageView.applyStyles(styles)
        infoMessageView.title = strings.chatEmptyTitle
        infoMessageView.message = strings.chatEmptyMessage
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
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.frame = bounds
    }
}

// MARK:- Utility

extension ChatMessagesView {

    func updateSubviewVisibility(_ animated: Bool = false) {
        let currentAlpha = infoMessageView.alpha
        var nextAlpha: CGFloat
        if dataSource.isEmpty() {
            nextAlpha = 1.0
        } else {
            nextAlpha = 0.0
        }
        
        if currentAlpha == nextAlpha {
            return
        }
    
        if animated {
            UIView.animate(withDuration: 0.3, animations: { 
                self.infoMessageView.alpha = nextAlpha
            })
        } else {
            infoMessageView.alpha = nextAlpha
        }
    }
    
    fileprivate func messageListPositionForIndexPath(_ indexPath: IndexPath) -> MessageListPosition {
        guard let messageEvent = dataSource.eventForIndexPath(indexPath) else { return .default }
        
        let messageIsReply = messageEventIsReply(messageEvent)
        let previousIsReply = messageEventIsReply(dataSource.getEvent(inSection: (indexPath as NSIndexPath).section, row: (indexPath as NSIndexPath).row - 1))
        let nextIsReply = messageEventIsReply(dataSource.getEvent(inSection: (indexPath as NSIndexPath).section, row: (indexPath as NSIndexPath).row + 1))
        
        if messageIsReply == previousIsReply && messageIsReply == nextIsReply {
            return .middleOfMany
        }
        if messageIsReply == nextIsReply {
            return .firstOfMany
        }
        if messageIsReply == previousIsReply {
            return .lastOfMany
        }
        
        return .default
    }
    
    fileprivate func messageEventIsReply(_ messageEvent: Event?) -> Bool? {
        guard let messageEvent = messageEvent else { return nil }
        
        return !messageEvent.wasSentByUserWithCredentials(credentials)
    }
}

// MARK:- UITableViewDataSource

extension ChatMessagesView: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Number of Item
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSections = dataSource.numberOfSections()
        if otherParticipantIsTyping {
            return max(1, numberOfSections)
        } else {
            return numberOfSections
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let lastSection = dataSource.numberOfSections() - 1
        if section == lastSection && otherParticipantIsTyping {
            return dataSource.numberOfRowsInSection(section) + 1
        }
        return dataSource.numberOfRowsInSection(section)
    }
    
    // MARK: Views / Cells
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < dataSource.numberOfSections() else { return nil }
  
        return cellMaster.timeStampHeaderView(withTimeStamp: dataSource.timeStampInSecondsForSection(section))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            srsItemViewCell.itemCarouselView.delegate = self
            srsItemViewCell.itemCarouselView.event = event
        }
        
        return cell ?? UITableViewCell()
    }

    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ChatTypingIndicatorCell {
            cell.loadingView.endAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         guard section < dataSource.numberOfSections() else { return 0.0 }
        
        return cellMaster.heightForTimeStampHeaderView(withTimeStamp: dataSource.timeStampInSecondsForSection(section))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        endEditing(true)
        delegate?.chatMessagesViewPerformedKeyboardHidingAction(self)
        
        let cell = tableView.cellForRow(at: indexPath)
        if let pictureCell = cell as? ChatPictureMessageCell,
            let event = pictureCell.event {
                delegate?.chatMessagesView(self, didTapImageView: pictureCell.pictureImageView, forEvent: event)
        } else if cell is ChatBubbleCell {
            toggleTimeStampForEventAtIndexPath(indexPath)
        }
        
        if let event = dataSource.eventForIndexPath(indexPath) {
            if event == dataSource.getLastEvent() {
                delegate?.chatMessagesView(self, didTapMostRecentEvent: event)
            }
        }   
    }
    
    func toggleTimeStampForEventAtIndexPath(_ indexPath: IndexPath) {
        
        let previousEvent = showTimeStampForEvent
        
        // Hide timestamp on previous cell
        if let previousEvent = showTimeStampForEvent,
            let previousIndexPath = dataSource.indexPathOfEvent(previousEvent),
            let previousCell = tableView.cellForRow(at: previousIndexPath) as? ChatBubbleCell {
            showTimeStampForEvent = nil
            previousCell.setDetailLabelHidden(true, animated: true)
        }

        if let nextEvent = dataSource.eventForIndexPath(indexPath) {
            // Show timestamp on next cell
            if previousEvent == nil || nextEvent != previousEvent {
                if let nextCell = tableView.cellForRow(at: indexPath) as? ChatBubbleCell {
                    showTimeStampForEvent = nextEvent
                    nextCell.setDetailLabelHidden(false, animated: true)
                }
            }
        }
        
        // Update cell heights
        if SystemVersionChecker.is8orEarlier() {
            tableView.reloadData()
        } else {
            tableView.beginUpdates()
            tableView.endUpdates()
            
        }
    }
}

// MARK:- SRSItemListViewDelegate

extension ChatMessagesView: SRSItemListViewDelegate {
    func itemListView(_ itemListView: SRSItemListView, didSelectButtonItem buttonItem: SRSButtonItem) {
        delegate?.chatMessagesView(self, didSelectButtonItem: buttonItem)
    }
}

// MARK:- SRSItemCarouselViewDelegate

extension ChatMessagesView: SRSItemCarouselViewDelegate {
    func itemCarouselView(_ itemCarouselView: SRSItemCarouselView, didScrollToPage page: Int) {
        if let event = itemCarouselView.event {
            delegate?.chatMessagesView(self, didUpdateButtonItemsForEvent: event)
        }
    }
}

// MARK:- Scroll

extension ChatMessagesView {
    
    func isNearBottom(_ delta: CGFloat = 80) -> Bool {
        let offsetWithDelta = tableView.contentOffset.y + delta
        let offsetAtBottom = tableView.contentSize.height - tableView.bounds.height
        if offsetWithDelta >= offsetAtBottom {
            return true
        }
        
        return false
    }
    
    func scrollToBottomIfNeeded(_ animated: Bool) {
        if !isNearBottom(10) {
            return
        }
        scrollToBottomAnimated(animated)
    }
    
    func scrollToBottomAnimated(_ animated: Bool) {
        var indexPath: IndexPath?
        let lastSection = numberOfSections(in: tableView) - 1
        if lastSection >= 0 {
            let lastRow = tableView(tableView, numberOfRowsInSection: lastSection) - 1
            if lastRow >= 0 {
                indexPath = IndexPath(row: lastRow, section: lastSection)
            }
        }
        
        if let indexPath = indexPath {
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: animated)
        }
    }
}

// MARK:- Typing Status / Preview

extension ChatMessagesView {
    
    func updateOtherParticipantTypingStatus(_ isTyping: Bool, withPreviewText previewText: String?) {
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
    
    func indexPathForTypingPreviewCell() -> IndexPath {
        let lastSection = dataSource.numberOfSections() - 1
        if lastSection < 0 {
            return IndexPath(row: 0, section: 0)
        } else {
            let lastRow = dataSource.numberOfRowsInSection(lastSection)
            return IndexPath(row: lastRow, section: lastSection)
        }
    }
}

// MARK:- Adding / Replacing Messages

extension ChatMessagesView {
    
    func replaceMessageEventsWithEvents(_ newMessageEvents: [Event]) {
        dataSource.reloadWithEvents(newMessageEvents)
        
        tableView.reloadData()
        
        updateSubviewVisibility()
    }
    
    func mergeMessageEventsWithEvents(_ newMessageEvents: [Event]) {
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
            tableView.scrollToRow(at: lastVisibleIndexPath, at: .bottom, animated: false)
        }
        
        updateSubviewVisibility()
    }
    
    func insertNewMessageEvent(_ event: Event, completion: (() -> Void)? = nil) {
        let wasNearBottom = isNearBottom()
        
        let indexPath = dataSource.addEvent(event)
        
        // Only animate the message if the user is near the bottom
        if cellAnimationsEnabled && wasNearBottom {
            eventsThatShouldAnimate.insert(event)
        }
        
        if let indexPath = indexPath {
            var previousIndexPath: IndexPath?
            if (indexPath as NSIndexPath).row > 0 {
                previousIndexPath = IndexPath(row: (indexPath as NSIndexPath).row - 1, section: (indexPath as NSIndexPath).section)
            }
            
            if SystemVersionChecker.is8orEarlier() {
                UIView.performWithoutAnimation({
                    self.tableView.reloadData()
                })
            } else {
                UIView.performWithoutAnimation({
                    self.tableView.beginUpdates()
                    if let previousIndexPath = previousIndexPath {
                        self.tableView.reloadRows(at: [previousIndexPath], with: .none)
                    }
                    if self.tableView.numberOfSections <= (indexPath as NSIndexPath).section {
                        self.tableView.insertSections(IndexSet(integer: (indexPath as NSIndexPath).section), with: .none)
                    } else {
                        self.tableView.insertRows(at: [indexPath], with: .none)
                    }
                    self.tableView.endUpdates()
                })
            }
        }
        
        if wasNearBottom {
            scrollToBottomAnimated(cellAnimationsEnabled)
        }
        
        updateSubviewVisibility(true)
        
        completion?()
    }
    
    func refreshMessageEvent(event: Event, completion: (() -> Void)? = nil) {
        if let indexPathToUpdate = dataSource.updateEvent(updatedEvent: event) {
            tableView.reloadRows(at: [indexPathToUpdate], with: .automatic)
        }
        completion?()
    }
}
