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
                          didTap button: QuickReply)
    
    func chatMessagesViewDidScrollNearBeginning(_ messagesView: ChatMessagesView)
    
    func chatMessagesViewShouldChangeAccessibilityFocus(_ messagesView: ChatMessagesView) -> Bool
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
    
    private lazy var loadingView: UIView = {
        let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: loadingHeaderHeight)
        loadingView.startAnimating()
        return loadingView
    }()
    
    var shouldShowLoadingHeader = false {
        didSet {
            tableView.tableHeaderView = shouldShowLoadingHeader ? loadingView : UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: .leastNonzeroMagnitude))
        }
    }
    
    var showTimeStampForMessage: ChatMessage?
    
    var hideTransientMessageButtons = false
    
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
    
    let pageSize = 100
    
    // MARK: - Private Properties
    
    private let cellAnimationsEnabled = true
    
    private var otherParticipantIsTyping: Bool = false
    
    private var isMoving = false
    
    internal var contentInset: UIEdgeInsets {
        set { tableView.contentInset = newValue }
        get { return tableView.contentInset }
    }
    
    private let defaultContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
    
    private let bottomPadding: CGFloat = -10
    
    private let loadingHeaderHeight: CGFloat = 60
    
    private var cellMaster: ChatMessagesViewCellMaster!
    
    private var dataSource: ChatMessagesViewDataSource!
    
    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    private var messagesThatShouldAnimate = Set<ChatMessage>()
    
    private var focusTimer: Timer?
    
    private var previousFocusedReply: ChatMessage?
    
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
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: .leastNonzeroMagnitude))
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
        focusTimer?.cancel()
        focusTimer = nil
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
    
    func clear() {
        cellMaster = ChatMessagesViewCellMaster(withTableView: tableView)
        dataSource = ChatMessagesViewDataSource()
        tableView.reloadData()
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
    
    private func shouldShowTransientButtons(for message: ChatMessage) -> Bool {
        return message == lastMessage && !hideTransientMessageButtons
    }
    
    private func shouldAnimateAttachment(for message: ChatMessage) -> Bool {
        return message == lastMessage && message.attachment?.shouldAnimate ?? false
    }
}

// MARK: - UITableViewDataSource

extension ChatMessagesView: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Number of Item
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSections = dataSource.numberOfSections()
        
        // typing indicator cell is always in the last section
        return max((otherParticipantIsTyping ? 1 : 0), numberOfSections)
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
        guard section < dataSource.numberOfSections() else {
            return nil
        }
  
        return cellMaster.timeStampHeaderView(withTime: dataSource.getHeaderTime(for: section))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = dataSource.getMessage(for: indexPath) else {
            let typingCell = cellMaster.typingIndicatorCell(for: indexPath)
            return typingCell ?? UITableViewCell()
        }
        
        let cell = cellMaster.cellForMessage(
            message,
            listPosition: messageListPositionForIndexPath(indexPath),
            detailsVisible: message == showTimeStampForMessage,
            transientButtonsVisible: shouldShowTransientButtons(for: message),
            shouldAnimate: shouldAnimateAttachment(for: message),
            atIndexPath: indexPath,
            delegate: self)
        
        return cell ?? UITableViewCell()
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let typingIndicatorCell = cell as? ChatTypingIndicatorCell {
            typingIndicatorCell.startAnimating()
            return
        }
        
        guard let message = dataSource.getMessage(for: indexPath) else {
            return
        }
        
        if !isMoving && indexPath.section == 0 && indexPath.row == 0 {
            notifyDelegateOfScrolling()
        }
        
        if cellAnimationsEnabled && messagesThatShouldAnimate.contains(message) {
            (cell as? ChatMessageCell)?.animate()
            messagesThatShouldAnimate.remove(message)
        }
    }
    
    private func notifyDelegateOfScrolling() {
        guard let firstVisibleIndexPath = tableView.indexPathsForVisibleRows?.first else {
            return
        }
        
        let messageIndex: Int?
        if let message = dataSource.getMessage(for: firstVisibleIndexPath) {
            messageIndex = allMessages?.index(of: message)
        } else {
            messageIndex = nil
        }
        
        if messageIndex ?? 0 <= pageSize / 2 {
            delegate?.chatMessagesViewDidScrollNearBeginning(self)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isMoving = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isMoving = false
        notifyDelegateOfScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        
        isMoving = false
        notifyDelegateOfScrolling()
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        isMoving = false
        notifyDelegateOfScrolling()
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        isMoving = true
        return true
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let typingIndicatorCell = cell as? ChatTypingIndicatorCell {
            typingIndicatorCell.loadingView.stopAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < dataSource.numberOfSections() else {
            return 0
        }
        
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
                                              transientButtonsVisible: shouldShowTransientButtons(for: message))
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

// MARK: - ChatMessageCellDelegate

extension ChatMessagesView: ChatMessageCellDelegate {
    
    func chatMessageCell(_ cell: ChatMessageCell,
                         didTap buttonItem: ButtonItem,
                         from message: ChatMessage) {
        delegate?.chatMessagesView(self, didTap: buttonItem, from: message)
    }
    
    func chatMessageCell(_ cell: ChatMessageCell, didTap button: QuickReply) {
        delegate?.chatMessagesView(self, didTap: button)
    }
    
    func chatMessageCell(_ cell: ChatMessageCell, didChangeHeightWith message: ChatMessage) {
        if let indexPath = dataSource.getIndexPath(of: message) {
            cellMaster.invalidateHeightOfCell(for: message)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
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
    
    private func getLastIndexPath() -> IndexPath? {
        var indexPath: IndexPath?
        let lastSection = numberOfSections(in: tableView) - 1
        
        if lastSection >= 0 {
            let lastRow = tableView(tableView, numberOfRowsInSection: lastSection) - 1
            if lastRow >= 0 {
                indexPath = IndexPath(row: lastRow, section: lastSection)
            }
        }
        
        return indexPath
    }
    
    private func scrollToRow(at indexPath: IndexPath, animated: Bool) {
        let scrollPadding: CGFloat = 1.0
        let indexRect = tableView.rectForRow(at: indexPath)
        let targetScrollYOffset = indexRect.origin.y
        guard fabs(tableView.contentOffset.y - targetScrollYOffset) > scrollPadding,
              tableView.contentSize.height > tableView.bounds.height - tableView.contentInset.vertical else {
            return
        }
        
        tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    func scrollToBottomAnimated(_ animated: Bool) {
        let scroll = { [weak self] in
            guard let strongSelf = self,
                  let indexPath = strongSelf.getLastIndexPath() else {
                return
            }
            
            strongSelf.scrollToRow(at: indexPath, animated: animated)
            strongSelf.focusAccessibilityOnLastMessage(delay: animated)
        }
        
        Dispatcher.performOnMainThread {
            scroll()
        }
    }
}

// MARK: - Typing Status / Preview

extension ChatMessagesView {
    
    func updateTypingStatus(_ isTyping: Bool, shouldRemove: Bool = true) {
        let isDifferent = isTyping != otherParticipantIsTyping
        let shouldScrollToBottom = isNearBottom() && isDifferent
        
        otherParticipantIsTyping = isTyping
        
        guard isDifferent && (isTyping || shouldRemove) else {
            return
        }
        
        let lastSection = dataSource.numberOfSections() - 1
        let lastRow = dataSource.numberOfRowsInSection(lastSection)
        tableView.beginUpdates()
        if isTyping {
            tableView.insertRows(at: [IndexPath(row: lastRow, section: lastSection)], with: .fade)
        } else {
            tableView.deleteRows(at: [IndexPath(row: lastRow, section: lastSection)], with: .fade)
        }
        tableView.endUpdates()

        if shouldScrollToBottom {
            tableView.scrollToRow(at: IndexPath(row: lastRow - 1, section: lastSection), at: .top, animated: true)
        }
    }
}

// MARK: - Adding / Replacing Messages

extension ChatMessagesView {
    func appendEvents(_ events: [Event]) {
        guard !events.isEmpty else {
            return
        }
        
        let messages = events.map { $0.chatMessage }.compactMap { $0 }
        dataSource.appendMessages(Array(messages))
        
        UIView.performWithoutAnimation { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func insertEvents(_ events: [Event]) {
        guard !events.isEmpty else {
            return
        }
        
        let messages = events.map { $0.chatMessage }.compactMap { $0 }
        let formerFirstMessage = dataSource.allMessages.first
        dataSource.insertMessages(Array(messages))
        let loadingIndicatorOffset: CGFloat = shouldShowLoadingHeader ? 0 : loadingHeaderHeight
        
        UIView.performWithoutAnimation { [tableView] in
            let distanceFromBottom = tableView.contentSize.height - tableView.contentOffset.y
            tableView.reloadData()
            
            if let formerFirst = dataSource?.getIndexPath(of: formerFirstMessage) {
                tableView.reloadRows(at: [formerFirst], with: .none)
            }
            
            let newOffsetY = tableView.contentSize.height - distanceFromBottom - loadingIndicatorOffset
            tableView.setContentOffset(CGPoint(x: 0, y: newOffsetY), animated: false)
        }
    }
    
    func reloadWithEvents(_ events: [Event]) {
        let countBefore = dataSource.allMessages.count
        
        hideTransientMessageButtons = events.last?.eventType == .accountMerge
        dataSource.reloadWithEvents(events)
        tableView.reloadData()
        
        if dataSource.allMessages.count != countBefore {
            scrollToBottomAnimated(false)
        }
    }
    
    func addMessage(_ message: ChatMessage, completion: (() -> Void)? = nil) {
        guard let indexPath = dataSource.addMessage(message) else {
            DebugLog.w(caller: self, "Failed to add message to view.")
            return
        }
        
        hideTransientMessageButtons = false
        
        // Only animate the message if the user is near the bottom
        let wasNearBottom = isNearBottom()
        if cellAnimationsEnabled && wasNearBottom {
            messagesThatShouldAnimate.insert(message)
        }
        
        tableView.reloadData()
        
        if let cell = tableView.cellForRow(at: indexPath) as? ChatMessageCell {
            cell.prepareForAnimation()
        }
        
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
    
    func focusAccessibilityOnLastMessage(delay: Bool) {
        func focus() {
            guard
                delegate?.chatMessagesViewShouldChangeAccessibilityFocus(self) == true,
                let firstOfRecentReplies = dataSource.getFirstOfRecentReplies()
            else {
                return
            }
            
            var message = firstOfRecentReplies
            if let previousFocused = previousFocusedReply,
                previousFocused.metadata.sendTime >= message.metadata.sendTime {
                guard let nextReply = dataSource.getReplyAfter(previousFocused) else {
                    return
                }
                message = nextReply
            }
            
            guard
                let indexPath = dataSource.getIndexPath(of: message),
                let cell = tableView.cellForRow(at: indexPath)
            else {
                return
            }
            
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, cell)
            
            focusTimer?.cancel()
            focusTimer = Timer(delay: .seconds(1)) { [weak self] in
                self?.previousFocusedReply = message
            }
            focusTimer?.start()
        }
        
        if delay {
            Dispatcher.delay(closure: focus)
        } else {
            focus()
        }
    }
}
