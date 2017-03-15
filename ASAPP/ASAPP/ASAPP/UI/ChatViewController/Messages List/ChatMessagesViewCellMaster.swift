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
    
    fileprivate let dateFormatter = DateFormatter()
    
    fileprivate let cellHeightCache = ChatMessageCellHeightCache()
    
    fileprivate var timeHeaderHeightCache = [Date : CGFloat]()
    
    fileprivate var cachedTypingIndicatorCellHeight: CGFloat?
    
    fileprivate var cachedTableViewWidth: CGFloat = 0.0 {
        didSet {
            if oldValue != cachedTableViewWidth {
                clearCache()
            }
        }
    }
    
    // MARK: Sizing Cells / Views
    
    fileprivate let timeHeaderSizingView = ChatMessagesTimeHeaderView(reuseIdentifier: nil)
    fileprivate let textMessageSizingCell = ChatMessageCell(style: .default, reuseIdentifier: nil)
    fileprivate let pictureMessageSizingCell = ChatPictureMessageCell(style: .default, reuseIdentifier: nil)
    fileprivate let typingIndicatorSizingCell = ChatTypingIndicatorCell(style: .default, reuseIdentifier: nil)
    fileprivate let itemListViewSizingCell = ChatItemListMessageCell(style: .default, reuseIdentifier: nil)
    fileprivate let itemCarouselViewSizingCell = ChatItemCarouselMessageCell(style: .default, reuseIdentifier: nil)
    
    // MARK: Reuse IDs
    
    fileprivate let TimeHeaderViewReuseId = "TimeHeaderViewReuseId"
    fileprivate let TypingIndicatorCellReuseId = "TypingIndicatorCellReuseId"
    
    // MARK: Init
    
    required init(withTableView tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        pictureMessageSizingCell.pictureView.disableImageLoading = true
        
        // Register Header & Non-Message Cells
        tableView.register(ChatMessagesTimeHeaderView.self, forHeaderFooterViewReuseIdentifier: TimeHeaderViewReuseId)
        tableView.register(ChatTypingIndicatorCell.self, forCellReuseIdentifier: TypingIndicatorCellReuseId)
        
        // Register Message Cells
        for messageType in ChatMessageType.all {
            tableView.register(getCellClass(for: messageType),
                               forCellReuseIdentifier: messageType.rawValue)
        }
    }
}

// MARK:- Utility Methods

extension ChatMessagesViewCellMaster {
    
    func clearCache() {
        cellHeightCache.clearCache()
        timeHeaderHeightCache.removeAll()
        cachedTypingIndicatorCellHeight = nil
    }
    
    fileprivate func getCellClass(for messageType: ChatMessageType) -> AnyClass {
        switch messageType {
        case .text: return ChatMessageCell.self
        case .itemList: return ChatItemListMessageCell.self
        case .itemCarousel: return ChatItemCarouselMessageCell.self
        case .picture: return ChatPictureMessageCell.self
        }
    }
    
    fileprivate func updateMessageCell(_ cell: ChatMessageCell?,
                                       with message: ChatMessage,
                                       listPosition: MessageListPosition,
                                       detailsVisible: Bool) {
        cell?.messagePosition = listPosition
        cell?.message = message
        cell?.isTimeLabelVisible = detailsVisible
    }
}

// MARK:- Header/Footer

extension ChatMessagesViewCellMaster {
    
    // MARK: Public
    
    func timeStampHeaderView(withTime time: Date?) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TimeHeaderViewReuseId) as? ChatMessagesTimeHeaderView
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

// MARK:- Cell Creation

extension ChatMessagesViewCellMaster {

    // MARK: Public
    
    func typingIndicatorCell(forIndexPath indexPath: IndexPath) -> UITableViewCell? {
        return getCell(with: TypingIndicatorCellReuseId, at: indexPath) as? ChatTypingIndicatorCell
    }
    
    func cellForMessage(_ message: ChatMessage,
                        listPosition: MessageListPosition,
                        detailsVisible: Bool,
                        atIndexPath indexPath: IndexPath) -> ChatMessageCell? {
        if let cell = getCell(with: message.type.rawValue, at: indexPath) as? ChatMessageCell {
            updateMessageCell(cell, with: message, listPosition: listPosition, detailsVisible: detailsVisible)
            return cell
        }
        return nil
    }
    
    // MARK: Private
    
    private func getCell(with identifier: String, at indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
}

// MARK:- Cell Heights

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
    
    func heightForCell(with message: ChatMessage?, listPosition: MessageListPosition, detailsVisible: Bool) -> CGFloat {
        guard let message = message else { return 0.0 }
        
        let canCacheHeight = !detailsVisible
        
        cachedTableViewWidth = tableView.bounds.width
        
        if canCacheHeight {
            if let cachedHeight = cellHeightCache.getCachedHeight(for: message, with: listPosition) {
                return cachedHeight
            }
        }
        
        // Calculate height
        let height: CGFloat = calculateHeightForCell(with: message,
                                                     listPosition: listPosition,
                                                     detailsVisible: detailsVisible,
                                                     width: cachedTableViewWidth)
        if canCacheHeight {
            cellHeightCache.cacheHeight(height, for: message, with: listPosition)
        }
                
        return height
    }
    
    // MARK: Private
    
    fileprivate func getMessageSizingCell(for message: ChatMessage) -> ChatMessageCell {
        switch message.type {
        case .itemList: return itemListViewSizingCell
        case .itemCarousel: return itemCarouselViewSizingCell
        case .picture: return pictureMessageSizingCell
        case .text: return textMessageSizingCell
        }
    }
    
    fileprivate func calculateHeightForCell(with message: ChatMessage,
                                            listPosition: MessageListPosition,
                                            detailsVisible: Bool,
                                            width: CGFloat) -> CGFloat {
        let sizingCell = getMessageSizingCell(for: message)
        updateMessageCell(sizingCell,
                          with: message,
                          listPosition: listPosition,
                          detailsVisible: detailsVisible)
        
        return heightForStyledView(sizingCell, width: width)
    }
    
    fileprivate func heightForStyledView(_ view: UIView, width: CGFloat) -> CGFloat {
        guard width > 0 else { return 0.0 }
        
        return ceil(view.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height)
    }
}
