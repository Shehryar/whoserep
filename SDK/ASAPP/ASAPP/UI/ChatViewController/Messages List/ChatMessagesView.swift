//
//  ChatMessagesView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatMessagesViewDelegate: class {
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTapImageView imageView: UIImageView,
                          forMessage message: ChatMessage)
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didSelectButtonItem buttonItem: SRSButtonItem,
                          forMessage message: ChatMessage)
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didUpdateButtonItemsForMessage message: ChatMessage)
    
    func chatMessagesViewPerformedKeyboardHidingAction(_ messagesView: ChatMessagesView)
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTapLastMessage message: ChatMessage)
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTap buttonItem: ButtonItem,
                          from message: ChatMessage)
}

class ChatMessagesView: UIView {
    
    // MARK:- Public Properties
    
    var contentInsetTop: CGFloat = 0 {
        didSet {
            var newContentInset = defaultContentInset
            newContentInset.top += max(0, contentInsetTop)
            contentInset = newContentInset
            tableView.scrollIndicatorInsets = UIEdgeInsetsMake(contentInsetTop, 0, 0, 0)
        }
    }
    
    weak var delegate: ChatMessagesViewDelegate?
    
    var showTimeStampForMessage: ChatMessage?
    
    var firstMessage: ChatMessage? {
        return dataSource.allMessages.first
    }
    
    var lastMessage: ChatMessage? {
        return dataSource.getLastMessage()
    }
    
    var numberOfMessages: Int {
        return dataSource.allMessages.count
    }
    
    var allMessages: [ChatMessage]? {
        return dataSource.allMessages
    }
    
    var isEmpty: Bool {
        return dataSource.isEmpty()
    }
    
    var overrideToHideInfoView = false {
        didSet {
            if oldValue != overrideToHideInfoView {
                updateSubviewVisibility()
            }
        }
    }
    
    // MARK:- Private Properties
    
    fileprivate let cellAnimationsEnabled = true
    
    fileprivate var otherParticipantIsTyping: Bool = false
        
    fileprivate var contentInset: UIEdgeInsets {
        set { tableView.contentInset = newValue }
        get { return tableView.contentInset }
    }
    
    fileprivate let defaultContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
    
    fileprivate var cellMaster: ChatMessagesViewCellMaster!
    
    fileprivate var dataSource: ChatMessagesViewDataSource!
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    fileprivate let emptyView = ChatMessagesEmptyView()
    
    fileprivate var messagesThatShouldAnimate = Set<ChatMessage>()
    
    // MARK:- Initialization
    
    func commonInit() {
        self.cellMaster = ChatMessagesViewCellMaster(withTableView: tableView)
        self.dataSource = ChatMessagesViewDataSource()
        
        
        backgroundColor = ASAPP.styles.primaryBackgroundColor
        clipsToBounds = false
        
        tableView.frame = bounds
        tableView.contentInset = defaultContentInset
        tableView.clipsToBounds = false
        tableView.backgroundColor = ASAPP.styles.primaryBackgroundColor
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
        
        emptyView.frame = bounds
        emptyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        emptyView.title = ASAPP.strings.chatEmptyTitle
        emptyView.message = ASAPP.strings.chatEmptyMessage
        addSubview(emptyView)
        
        updateSubviewVisibility()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
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
    
    // MARK: Display
    
    func updateDisplay() {
        cellMaster.clearCache()
        tableView.reloadData()
        
        scrollToBottomAnimated(false)
    }
}

// MARK:- Utility

extension ChatMessagesView {

    func updateSubviewVisibility(_ animated: Bool = false) {
        let currentAlpha = emptyView.alpha
        var nextAlpha: CGFloat
        if overrideToHideInfoView || !dataSource.isEmpty() {
            nextAlpha = 0.0
        } else {
            nextAlpha = 1.0
        }
        
        if currentAlpha == nextAlpha {
            return
        }
    
        if animated {
            UIView.animate(withDuration: 0.3, animations: { 
                self.emptyView.alpha = nextAlpha
            })
        } else {
            emptyView.alpha = nextAlpha
        }
    }
    
    fileprivate func messageListPositionForIndexPath(_ indexPath: IndexPath) -> MessageListPosition {
        guard let message = dataSource.getMessage(for: indexPath) else { return .none }
        
        let section = indexPath.section
        let previousRow = indexPath.row - 1
        let nextRow = indexPath.row + 1
        
        let previousIsReply = dataSource.getMessage(in: section, at: previousRow)?.isReply
        let nextIsReply = dataSource.getMessage(in: section, at: nextRow)?.isReply
        
        if message.isReply == previousIsReply && message.isReply == nextIsReply {
            return .middleOfMany
        }
        if message.isReply == nextIsReply {
            return .firstOfMany
        }
        if message.isReply == previousIsReply {
            return .lastOfMany
        }
        
        return .none
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
  
        return cellMaster.timeStampHeaderView(withTime: dataSource.getHeaderTime(for: section))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = dataSource.getMessage(for: indexPath) else {
            let typingCell = cellMaster.typingIndicatorCell(forIndexPath: indexPath)
            return typingCell ?? UITableViewCell()
        }
        
        let cell = cellMaster.cellForMessage(message,
                                             listPosition: messageListPositionForIndexPath(indexPath),
                                             detailsVisible: message == showTimeStampForMessage,
                                             atIndexPath: indexPath)
        cell?.delegate = self
        
        return cell ?? UITableViewCell()
    }

    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let isTypingCell = cell as? ChatTypingIndicatorCell {
            isTypingCell.startAnimating()
            return
        }
        
        guard let message = dataSource.getMessage(for: indexPath) else {
            return
        }
        
        if cellAnimationsEnabled && messagesThatShouldAnimate.contains(message) {
            (cell as? ChatMessageCell)?.animate()
            messagesThatShouldAnimate.remove(message)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ChatTypingIndicatorCell {
            cell.loadingView.stopAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         guard section < dataSource.numberOfSections() else { return 0.0 }
        
        return cellMaster.heightForTimeStampHeaderView(withTime: dataSource.getHeaderTime(for: section))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let message = dataSource.getMessage(for: indexPath) else {
            return cellMaster.heightForTypingIndicatorCell()
        }
        
        let listPosition = messageListPositionForIndexPath(indexPath)
        let height = cellMaster.heightForCell(with: message,
                                              listPosition: listPosition,
                                              detailsVisible: message == showTimeStampForMessage)
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        endEditing(true)
        delegate?.chatMessagesViewPerformedKeyboardHidingAction(self)
        
        let cell = tableView.cellForRow(at: indexPath)
        if let pictureCell = cell as? ChatPictureMessageCell,
            let message = pictureCell.message {
                delegate?.chatMessagesView(self,
                                           didTapImageView: pictureCell.pictureView.imageView,
                                           forMessage: message)
        } else if cell is ChatMessageCell {
            toggleTimeStampForMessage(at: indexPath)
        }
        
        if let message = dataSource.getMessage(for: indexPath) {
            if message == dataSource.getLastMessage() {
                delegate?.chatMessagesView(self, didTapLastMessage: message)
            }
        }   
    }
    
    func toggleTimeStampForMessage(at indexPath: IndexPath) {
        
        let previousMessage = showTimeStampForMessage
        
        // Hide timestamp on previous cell
        if let previousMessage = previousMessage,
            let previousIndexPath = dataSource.getIndexPath(of: previousMessage),
            let previousCell = tableView.cellForRow(at: previousIndexPath) as? ChatMessageCell {
                showTimeStampForMessage = nil
                previousCell.setTimeLabelVisible(false, animated: true)
        }

        if let nextMessage = dataSource.getMessage(for: indexPath) {
            // Show timestamp on next cell
            if previousMessage == nil || nextMessage != previousMessage {
                if let nextCell = tableView.cellForRow(at: indexPath) as? ChatMessageCell {
                    showTimeStampForMessage = nextMessage
                    nextCell.setTimeLabelVisible(true, animated: true)
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

extension ChatMessagesView: ChatMessageCellDelegate {
    
    func chatMessageCell(_ cell: ChatMessageCell, withItemCarouselView view: SRSItemCarouselView, didScrollToPage page: Int) {
        if let message = cell.message {
            delegate?.chatMessagesView(self, didUpdateButtonItemsForMessage: message)
        } else {
            DebugLog.e("Missing event on itemCarouselView")
        }
    }
    
    func chatMessageCell(_ cell: ChatMessageCell, withItemCarouselView view: SRSItemCarouselView, didSelectButtonItem buttonItem: SRSButtonItem) {
        if let message = cell.message {
            delegate?.chatMessagesView(self, didSelectButtonItem: buttonItem, forMessage: message)
        } else {
            DebugLog.e("Missing event on itemCarouselView")
        }
    }
    
    func chatMessageCell(_ cell: ChatMessageCell, withItemListView view: SRSItemListView, didSelectButtonItem buttonItem: SRSButtonItem) {
        if let message = cell.message {
            delegate?.chatMessagesView(self, didSelectButtonItem: buttonItem, forMessage: message)
        } else {
            DebugLog.e("Missing event on itemListView")
        }
    }
    
    func chatMessageCell(_ cell: ChatMessageCell,
                         didTap buttonItem: ButtonItem,
                         from message: ChatMessage) {
        delegate?.chatMessagesView(self, didTap: buttonItem, from: message)
    }
}

// MARK:- Scroll

extension ChatMessagesView {
    
    func isNearBottom(_ delta: CGFloat = 120) -> Bool {
        let offsetWithDelta = tableView.contentOffset.y + delta
        let offsetAtBottom = tableView.contentSize.height - tableView.bounds.height - tableView.contentInset.bottom
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
            if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "9.0") {
                tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
            } else {
                // iOS 8 and below bug
                Dispatcher.performOnMainThread { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
            }
        }
    }
    
    func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) != .orderedAscending
    }
}

// MARK:- Typing Status / Preview

extension ChatMessagesView {
    
    func updateTypingStatus(_ isTyping: Bool) {
        let isDifferent = isTyping != otherParticipantIsTyping
        let shouldScrollToBottom = isNearBottom() && isDifferent && isTyping
        
        otherParticipantIsTyping = isTyping
        
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
    
    func reloadWithEvents(_ events: [Event]) {
        let countBefore = dataSource.allMessages.count
        
        dataSource.reloadWithEvents(events)
        tableView.reloadData()
        updateSubviewVisibility()
        
        if dataSource.allMessages.count != countBefore {
            scrollToBottomAnimated(false)
        }
        return
    }
    
    func addMessage(_ message: ChatMessage, completion: (() -> Void)? = nil) {
        guard let indexPath = dataSource.addMessage(message) else {
            DebugLog.w(caller: self, "Failed to add message to view.")
            return
        }
        
        // Only animate the message if the user is near the bottom
        let wasNearBottom = isNearBottom()
        if cellAnimationsEnabled && wasNearBottom {
            messagesThatShouldAnimate.insert(message)
        }
        
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
        
        focusAccessibilityOnLastMessage()
        
        if wasNearBottom {
            scrollToBottomAnimated(cellAnimationsEnabled)
        }
        
        updateSubviewVisibility(true)
        
        completion?()
    }
    
    func updateMessage(_ message: ChatMessage, completion: (() -> Void)? = nil) {
        if let indexPath = dataSource.updateMessage(message) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        completion?()
    }
    
    func focusAccessibilityOnLastMessage() {
        if let lastCell = tableView.visibleCells.last {
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, lastCell)
        }
    }
}
