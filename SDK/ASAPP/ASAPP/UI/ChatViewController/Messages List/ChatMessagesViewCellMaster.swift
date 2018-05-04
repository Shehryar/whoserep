//
//  ChatMessagesViewCellMaster.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/17/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum MessageListPosition {
    case none
    case firstOfMany
    case middleOfMany
    case lastOfMany
}

class ChatMessagesViewCellMaster: NSObject {
    
    // MARK: Public Properties

    let tableView: UITableView
    
    // MARK: Private Properties
    
    private let dateFormatter = DateFormatter()
    
    private let cellHeightCache = ChatMessageCellHeightCache()
    
    private var timeHeaderHeightCache = [Date: CGFloat]()
    
    private var cachedTypingIndicatorCellHeight: CGFloat?
    
    private var cachedTableViewWidth: CGFloat = 0.0 {
        didSet {
            if oldValue != cachedTableViewWidth {
                clearCache()
            }
        }
    }
    
    // MARK: Sizing Cells / Views
    
    private let timeHeaderSizingView = ChatMessagesTimeHeaderView(reuseIdentifier: nil)
    private let textMessageSizingCell = ChatMessageCell(style: .default, reuseIdentifier: nil)
    private let pictureMessageSizingCell = ChatPictureMessageCell(style: .default, reuseIdentifier: nil)
    private let typingIndicatorSizingCell = ChatTypingIndicatorCell(style: .default, reuseIdentifier: nil)
    private let componentViewSizingCell = ChatComponentViewMessageCell(style: .default, reuseIdentifier: nil)
    
    // MARK: Reuse IDs
    
    private let timeHeaderViewReuseId = "TimeHeaderViewReuseId"
    private let typingIndicatorCellReuseId = "TypingIndicatorCellReuseId"
    
    // MARK: Init
    
    required init(withTableView tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        pictureMessageSizingCell.pictureView.disableImageLoading = true
        
        // Register Header & Non-Message Cells
        tableView.register(ChatMessagesTimeHeaderView.self, forHeaderFooterViewReuseIdentifier: timeHeaderViewReuseId)
        tableView.register(ChatTypingIndicatorCell.self, forCellReuseIdentifier: typingIndicatorCellReuseId)
        
        // Register Message Cells
        for type in ChatMessageAttachment.AttachmentType.all {
            tableView.register(getCellClass(for: type), forCellReuseIdentifier: getCellReuseId(for: type))
        }
    }
}

// MARK: - Utility Methods

extension ChatMessagesViewCellMaster {
    
    func clearCache() {
        cellHeightCache.clearCache()
        timeHeaderHeightCache.removeAll()
        cachedTypingIndicatorCellHeight = nil
    }
    
    private func getCellClass(for attachmentType: ChatMessageAttachment.AttachmentType) -> AnyClass {
        switch attachmentType {
        case .none: return ChatMessageCell.self
        case .image: return ChatPictureMessageCell.self
        case .template: return ChatComponentViewMessageCell.self
        }
    }
    
    private func getCellReuseId(for type: ChatMessageAttachment.AttachmentType?) -> String {
        let prefix = "MessageCellReuseId_"
        if let type = type {
            return prefix + type.rawValue
        }
        return prefix + ChatMessageAttachment.AttachmentType.none.rawValue
    }
    
    private func getMessageSizingCell(forAttachmentType type: ChatMessageAttachment.AttachmentType?) -> ChatMessageCell {
        if let type = type {
            switch type {
            case .none: return textMessageSizingCell
            case .image: return pictureMessageSizingCell
            case .template: return componentViewSizingCell
            }
            
        }
        return textMessageSizingCell
    }
    
    private func updateMessageCell(_ cell: ChatMessageCell?,
                                   with message: ChatMessage,
                                   listPosition: MessageListPosition,
                                   detailsVisible: Bool,
                                   buttonsVisible: Bool) {
        cell?.messagePosition = listPosition
        cell?.update(message, showButtons: buttonsVisible)
        cell?.isAccessibilityElement = true
        cell?.accessibilityLabel = message.text
        cell?.isTimeLabelVisible = detailsVisible
    }
}

// MARK: - Header/Footer

extension ChatMessagesViewCellMaster {
    
    // MARK: Public
    
    func timeStampHeaderView(withTime time: Date?) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: timeHeaderViewReuseId) as? ChatMessagesTimeHeaderView
        styleTimeHeaderView(headerView, withTime: time)
        return headerView
    }
    
    func heightForTimeStampHeaderView(withTime time: Date?) -> CGFloat {
        guard let time = time else { return 0.0 }
        
        cachedTableViewWidth = tableView.bounds.width
        if let cachedHeight = timeHeaderHeightCache[time] {
            return cachedHeight
        }
        
        styleTimeHeaderView(timeHeaderSizingView, withTime: time)
        
        let height = heightForStyledView(timeHeaderSizingView, width: cachedTableViewWidth)
        timeHeaderHeightCache[time] = height
        
        return height
    }
    
    // MARK: Private
    
    private func styleTimeHeaderView(_ view: ChatMessagesTimeHeaderView?, withTime time: Date?) {
        view?.time = time
    }
}

// MARK: - Cell Creation

extension ChatMessagesViewCellMaster {

    // MARK: Public
    
    func typingIndicatorCell(for indexPath: IndexPath) -> UITableViewCell? {
        return getCell(with: typingIndicatorCellReuseId, at: indexPath) as? ChatTypingIndicatorCell
    }
    
    func cellForMessage(_ message: ChatMessage,
                        listPosition: MessageListPosition,
                        detailsVisible: Bool,
                        buttonsVisible: Bool,
                        atIndexPath indexPath: IndexPath) -> ChatMessageCell? {
        let reuseId = getCellReuseId(for: message.attachment?.type)
        if let cell = getCell(with: reuseId, at: indexPath) as? ChatMessageCell {
            updateMessageCell(
                cell,
                with: message,
                listPosition: listPosition,
                detailsVisible: detailsVisible,
                buttonsVisible: buttonsVisible)
            return cell
        }
        return nil
    }
    
    // MARK: Private
    
    private func getCell(with identifier: String, at indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
}

// MARK: - Cell Heights

extension ChatMessagesViewCellMaster {
    
    // MARK: Public
    
    func heightForTypingIndicatorCell() -> CGFloat {
        if let cachedHeight = cachedTypingIndicatorCellHeight {
            return cachedHeight
        }

        cachedTableViewWidth = tableView.bounds.width
        cachedTypingIndicatorCellHeight = heightForStyledView(typingIndicatorSizingCell, width: cachedTableViewWidth)
        
        return cachedTypingIndicatorCellHeight ?? 0.0
    }
    
    func heightForCell(with message: ChatMessage?,
                       listPosition: MessageListPosition,
                       detailsVisible: Bool,
                       buttonsVisible: Bool) -> CGFloat {
        guard let message = message else { return 0.0 }
        
        let canCacheHeight = !detailsVisible
        
        cachedTableViewWidth = tableView.bounds.width
        
        if canCacheHeight {
            if let cachedHeight = cellHeightCache.getCachedHeight(for: message, with: listPosition, buttonsVisible: buttonsVisible) {
                return cachedHeight
            }
        }
        
        // Calculate height
        let height: CGFloat = calculateHeightForCell(with: message,
                                                     listPosition: listPosition,
                                                     detailsVisible: detailsVisible,
                                                     buttonsVisible: buttonsVisible,
                                                     width: cachedTableViewWidth)
        if canCacheHeight {
            cellHeightCache.cacheHeight(height, for: message, with: listPosition, buttonsVisible: buttonsVisible)
        }
                
        return height
    }
    
    // MARK: Private
    
    private func calculateHeightForCell(with message: ChatMessage,
                                        listPosition: MessageListPosition,
                                        detailsVisible: Bool,
                                        buttonsVisible: Bool,
                                        width: CGFloat) -> CGFloat {
        let sizingCell = getMessageSizingCell(forAttachmentType: message.attachment?.type)
        updateMessageCell(sizingCell,
                          with: message,
                          listPosition: listPosition,
                          detailsVisible: detailsVisible,
                          buttonsVisible: buttonsVisible)
        
        return heightForStyledView(sizingCell, width: width)
    }
    
    private func heightForStyledView(_ view: UIView, width: CGFloat) -> CGFloat {
        guard width > 0 else { return 0.0 }
        
        return ceil(view.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height)
    }
}
