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
                          from message: ChatMessage)
    
    func chatMessagesViewPerformedKeyboardHidingAction(_ messagesView: ChatMessagesView)
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didUpdateQuickRepliesFrom message: ChatMessage)
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTap buttonItem: ButtonItem,
                          from message: ChatMessage)
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTapButtonWith action: Action)
}

class ChatMessagesView: UIView {
    
    // MARK: - Public Properties
    
    var contentInsetTop: CGFloat = 0 {
        didSet {
            var newContentInset = contentInset
            newContentInset.top = contentInsetTop
            contentInset = newContentInset
            let scrollInsets = tableView.scrollIndicatorInsets
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: contentInsetTop, left: scrollInsets.left, bottom: scrollInsets.bottom, right: scrollInsets.right)
        }
    }
    
    var contentInsetBottom: CGFloat = 0 {
        didSet {
            var newContentInset = contentInset
            newContentInset.bottom = contentInsetBottom + bottomPadding
            contentInset = newContentInset
            let scrollInsets = tableView.scrollIndicatorInsets
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: scrollInsets.top, left: scrollInsets.left, bottom: contentInsetBottom, right: scrollInsets.right)
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
    
    // MARK: - Private Properties
    
    private let cellAnimationsEnabled = true
    
    private var otherParticipantIsTyping: Bool = false
    
    internal var contentInset: UIEdgeInsets {
        set { tableView.contentInset = newValue }
        get { return tableView.contentInset }
    }
    
    private let defaultContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
    
    private let bottomPadding: CGFloat = 10
    
    private var cellMaster: ChatMessagesViewCellMaster!
    
    private var dataSource: ChatMessagesViewDataSource!
    
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    private var messagesThatShouldAnimate = Set<ChatMessage>()
    
    // MARK: - Initialization
    
    func commonInit() {
        self.cellMaster = ChatMessagesViewCellMaster(withTableView: tableView)
        self.dataSource = ChatMessagesViewDataSource()
        
        backgroundColor = .clear
        clipsToBounds = false
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.frame = bounds
        tableView.contentInset = defaultContentInset
        tableView.estimatedRowHeight = 0
        tableView.clipsToBounds = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
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

// MARK: - Utility

extension ChatMessagesView {    
    private func messageListPositionForIndexPath(_ indexPath: IndexPath) -> MessageListPosition {
        guard let message = dataSource.getMessage(for: indexPath) else { return .none }
        
        let section = indexPath.section
        let previousRow = indexPath.row - 1
        let nextRow = indexPath.row + 1
        
        let previousIsReply = dataSource.getMessage(in: section, at: previousRow)?.metadata.isReply
        let nextIsReply = dataSource.getMessage(in: section, at: nextRow)?.metadata.isReply
        
        if message.metadata.isReply == previousIsReply && message.metadata.isReply == nextIsReply {
            return .middleOfMany
        }
        if message.metadata.isReply == nextIsReply {
            return .firstOfMany
        }
        if message.metadata.isReply == previousIsReply {
            return .lastOfMany
        }
        
        return .none
    }
}

// MARK: - UITableViewDataSource

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
                                             buttonsVisible: message == lastMessage,
                                             atIndexPath: indexPath)
        cell?.delegate = self
        
        return cell ?? UITableViewCell()
    }

    // MARK: - UITableViewDelegate
    
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: .leastNonzeroMagnitude))
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let message = dataSource.getMessage(for: indexPath) else {
            return cellMaster.heightForTypingIndicatorCell()
        }
        
        let listPosition = messageListPositionForIndexPath(indexPath)
        let height = cellMaster.heightForCell(with: message,
                                              listPosition: listPosition,
                                              detailsVisible: message == showTimeStampForMessage,
                                              buttonsVisible: message == lastMessage)
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
                                           from: message)
        } else if cell is ChatMessageCell {
            toggleTimeStampForMessage(at: indexPath)
        }
        
        if let message = dataSource.getMessage(for: indexPath) {
            if message == dataSource.getLastMessage() {
                if isNearBottom() {
                    scrollToBottomAnimated(false)
                }
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
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: - SRSItemListViewDelegate

extension ChatMessagesView: ChatMessageCellDelegate {
    
    func chatMessageCell(_ cell: ChatMessageCell, didPageCarouselViewItem: CarouselViewItem, from: ComponentView) {
        if let message = cell.message {
            delegate?.chatMessagesView(self, didUpdateQuickRepliesFrom: message)
        }
    }
    
    func chatMessageCell(_ cell: ChatMessageCell,
                         didTap buttonItem: ButtonItem,
                         from message: ChatMessage) {
        delegate?.chatMessagesView(self, didTap: buttonItem, from: message)
    }
    
    func chatMessageCell(_ cell: ChatMessageCell, didTapButtonWith action: Action) {
        delegate?.chatMessagesView(self, didTapButtonWith: action)
    }
}

// MARK: - Scroll

extension ChatMessagesView {
    
    func isNearBottom(_ delta: CGFloat = 120) -> Bool {
        let offsetWithDelta = tableView.contentOffset.y + delta
        let offsetAtBottom = tableView.contentSize.height + tableView.contentInset.bottom - tableView.bounds.height
        if offsetWithDelta >= offsetAtBottom {
            return true
        }
        
        return false
    }
    
    func scrollToBottomAnimated(_ animated: Bool) {
        let scroll = { [weak self] in
            guard let strongSelf = self else { return }
            
            var indexPath: IndexPath?
            let lastSection = strongSelf.numberOfSections(in: strongSelf.tableView) - 1
            if lastSection >= 0 {
                let lastRow = strongSelf.tableView(strongSelf.tableView, numberOfRowsInSection: lastSection) - 1
                if lastRow >= 0 {
                    indexPath = IndexPath(row: lastRow, section: lastSection)
                }
            }
            
            if let indexPath = indexPath {
                strongSelf.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
            }
        }
        
        if #available(iOS 11, *) {
            if !isNearBottom(10) && animated {
                Dispatcher.delay(200, closure: scroll)
            } else {
                scroll()
            }
        } else {
            scroll()
        }
    }
}

// MARK: - Typing Status / Preview

extension ChatMessagesView {
    
    func updateTypingStatus(_ isTyping: Bool) {
        let isDifferent = isTyping != otherParticipantIsTyping
        let shouldScrollToBottom = isNearBottom() && isDifferent && isTyping
        
        otherParticipantIsTyping = isTyping
        
        if isDifferent {
            let lastSection = dataSource.numberOfSections() - 1
            let lastRow = dataSource.numberOfRowsInSection(lastSection)
            let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
            if isTyping {
                tableView.insertRows(at: [lastIndexPath], with: .none)
            } else {
                tableView.deleteRows(at: [lastIndexPath], with: .none)
            }
        }
        
        if shouldScrollToBottom {
            scrollToBottomAnimated(false)
        }
    }
}

// MARK: - Adding / Replacing Messages

extension ChatMessagesView {
    
    func reloadWithEvents(_ events: [Event]) {
        let countBefore = dataSource.allMessages.count
        
        dataSource.reloadWithEvents(events)
        tableView.reloadData()
        
        if dataSource.allMessages.count != countBefore {
            scrollToBottomAnimated(false)
        }
        return
    }
    
    func addMessage(_ message: ChatMessage, completion: (() -> Void)? = nil) {
        var rowsToReload: [IndexPath] = []
        
        if let previousLastIndexPath = dataSource.getLastIndexPath() {
            rowsToReload.append(previousLastIndexPath)
        }
        
        guard let indexPath = dataSource.addMessage(message) else {
            DebugLog.w(caller: self, "Failed to add message to view.")
            return
        }
        
        // Only animate the message if the user is near the bottom
        let wasNearBottom = isNearBottom()
        if cellAnimationsEnabled && wasNearBottom {
            messagesThatShouldAnimate.insert(message)
        }
        
        if indexPath.row > 0 {
            let previousIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if !rowsToReload.contains(previousIndexPath) {
                rowsToReload.append(previousIndexPath)
            }
        }
        
        UIView.performWithoutAnimation({
            self.tableView.beginUpdates()
            if !rowsToReload.isEmpty {
                self.tableView.reloadRows(at: rowsToReload, with: .none)
            }
            
            if self.tableView.numberOfSections <= indexPath.section {
                self.tableView.insertSections(IndexSet(integer: indexPath.section), with: .none)
            } else {
                self.tableView.insertRows(at: [indexPath], with: .none)
            }
            self.tableView.endUpdates()
        })
        
        focusAccessibilityOnLastMessage()
        
        if wasNearBottom {
            scrollToBottomAnimated(cellAnimationsEnabled)
        }
        
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
