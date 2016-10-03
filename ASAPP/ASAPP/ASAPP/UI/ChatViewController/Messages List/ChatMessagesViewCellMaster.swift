//
//  ChatMessagesViewCellMaster.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/17/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesViewCellMaster: NSObject, ASAPPStyleable {

    // MARK: Public Properties

    let tableView: UITableView
    
    // MARK: Private Properties
    
    fileprivate let dateFormatter = DateFormatter()
    
    fileprivate var cellHeightCache = [Event : CGFloat]()
    
    fileprivate var timeHeaderHeightCache = [Double : CGFloat]()
    
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
    fileprivate let textMessageSizingCell = ChatTextMessageCell(style: .default, reuseIdentifier: nil)
    fileprivate let pictureMessageSizingCell = ChatPictureMessageCell(style: .default, reuseIdentifier: nil)
    fileprivate let typingIndicatorSizingCell = ChatTypingIndicatorCell(style: .default, reuseIdentifier: nil)
    fileprivate let typingPreviewSizingCell = ChatTypingPreviewCell(style: .default, reuseIdentifier: nil)
    fileprivate let srsItemListViewSizingCell = ChatSRSItemListViewCell(style: .default, reuseIdentifier: nil)
    fileprivate let infoTextSizingCell = ChatInfoTextCell(style: .default, reuseIdentifier: nil)
    
    // MARK: Reuse IDs
    
    fileprivate let TimeHeaderViewReuseId = "TimeHeaderViewReuseId"
    
    fileprivate let TextMessageCellReuseId = "TextMessageCellReuseId"
    fileprivate let PictureMessageCellReuseId = "PictureMessageCellReuseId"
    fileprivate let TypingIndicatorCellReuseId = "TypingIndicatorCellReuseId"
    fileprivate let TypingPreviewCellReuseId = "TypingPreviewCellReuseId"
    fileprivate let SRSResponseCellReuseId = "SRSResponseCellReuseId"
    fileprivate let InfoTextCellReuseId = "InfoTextCellReuseId"
    
    // MARK: Init
    
    required init(withTableView tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        pictureMessageSizingCell.disableImageLoading = true
        
        // Register Header
        tableView.register(ChatMessagesTimeHeaderView.self, forHeaderFooterViewReuseIdentifier: TimeHeaderViewReuseId)
        
        // Register Cells
        tableView.register(ChatTextMessageCell.self, forCellReuseIdentifier: TextMessageCellReuseId)
        tableView.register(ChatPictureMessageCell.self, forCellReuseIdentifier: PictureMessageCellReuseId)
        tableView.register(ChatTypingIndicatorCell.self, forCellReuseIdentifier: TypingIndicatorCellReuseId)
        tableView.register(ChatTypingPreviewCell.self, forCellReuseIdentifier: TypingPreviewCellReuseId)
        tableView.register(ChatSRSItemListViewCell.self, forCellReuseIdentifier: SRSResponseCellReuseId)
        tableView.register(ChatInfoTextCell.self, forCellReuseIdentifier: InfoTextCellReuseId)
    }
    
    // MARK: ASAPPStyleable
    
    fileprivate(set) var styles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        clearCache()
    }
}

// MARK:- Private Methods

extension ChatMessagesViewCellMaster {
    
    func clearCache() {
        cellHeightCache.removeAll()
        timeHeaderHeightCache.removeAll()
        cachedTypingIndicatorCellHeight = nil
    }
}

// MARK:- Header/Footer

extension ChatMessagesViewCellMaster {
    
    func timeStampHeaderView(withTimeStamp timeStamp: Double) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TimeHeaderViewReuseId) as? ChatMessagesTimeHeaderView
        headerView?.applyStyles(styles)
        headerView?.timeStampInSeconds = timeStamp
        return headerView
    }
    
    func heightForTimeStampHeaderView(withTimeStamp timeStamp: Double?) -> CGFloat {
        guard let timeStamp = timeStamp else { return 0.0 }
        
        cachedTableViewWidth = tableView.bounds.width
        
        if let cachedHeight = timeHeaderHeightCache[timeStamp] {
            return cachedHeight
        }
        
        timeHeaderSizingView.applyStyles(styles)
        timeHeaderSizingView.timeStampInSeconds = timeStamp
        
        let height = heightForStyledView(timeHeaderSizingView, width: cachedTableViewWidth)
        timeHeaderHeightCache[timeStamp] = height
        
        return height
    }
}

// MARK:- Cell Creation

extension ChatMessagesViewCellMaster {

    func typingIndicatorCell(forIndexPath indexPath: IndexPath) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: TypingIndicatorCellReuseId) as? ChatTypingIndicatorCell
        cell?.applyStyles(styles, isReply: true)
        cell?.listPosition = .default
        return cell ?? UITableViewCell()
    }
    
    func typingPreviewCell(forIndexPath indexPath: IndexPath, withText text: String?) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: TypingPreviewCellReuseId) as? ChatTypingPreviewCell
        cell?.messageText = text
        cell?.applyStyles(styles, isReply: true)
        return cell
    }
    
    func cellForEvent(_ event: Event, isReply: Bool, listPosition: MessageListPosition, detailsVisible: Bool, atIndexPath: IndexPath) -> UITableViewCell? {
        
        // Picture Message
        if event.eventType == .pictureMessage {
            let cell = tableView.dequeueReusableCell(withIdentifier: PictureMessageCellReuseId) as? ChatPictureMessageCell
            cell?.applyStyles(styles, isReply: isReply)
            cell?.listPosition = listPosition
            cell?.event = event
            return cell
        }
        
        // Text Message
        if event.eventType == .textMessage {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextMessageCellReuseId) as? ChatTextMessageCell
            cell?.applyStyles(styles, isReply: isReply)
            cell?.listPosition = listPosition
            cell?.event = event
            cell?.messageText = event.textMessage?.text
            cell?.detailLabelHidden = !detailsVisible
            return cell
        }
        
        // SRS Response
        if event.eventType == .srsResponse {
            if let srsResponse = event.srsResponse {
                switch srsResponse.displayType {
                case .Inline, .ActionSheet:
                    let cell = tableView.dequeueReusableCell(withIdentifier: SRSResponseCellReuseId) as? ChatSRSItemListViewCell
                    cell?.applyStyles(styles, isReply: isReply)
                    cell?.listPosition = listPosition
                    cell?.event = event
                    cell?.response = srsResponse
                    cell?.detailLabelHidden = !detailsVisible
                    return cell
                }
            }
        }
        
        // Info Cell
        if [EventType.crmCustomerLinked, EventType.newIssue, EventType.newRep].contains(event.eventType) {
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoTextCellReuseId) as? ChatInfoTextCell
            cell?.applyStyles(styles)
            
            switch event.eventType {
            case .crmCustomerLinked:
                cell?.infoText = ASAPPLocalizedString("Customer Linked")
                break
                
            case .newIssue:
                cell?.infoText = ASAPPLocalizedString("New Issue: \(event.newIssue?.issueId ?? 0)")
                break
                
            case .newRep:
                cell?.infoText = ASAPPLocalizedString("New Rep: \(event.newRep?.name ?? String(describing: event.newRep?.repId))")
                break
                
            default:  // Other cases not handled
                break
            }
            
            return cell ?? UITableViewCell()
        }

        
        return nil
    }
}

// MARK:- Cell Heights

extension ChatMessagesViewCellMaster {
    
    func heightForTypingIndicatorCell() -> CGFloat {
        if let cachedHeight = cachedTypingIndicatorCellHeight {
            return cachedHeight
        }

        typingIndicatorSizingCell.applyStyles(styles, isReply: true)
        cachedTableViewWidth = tableView.bounds.width
        cachedTypingIndicatorCellHeight = heightForStyledView(typingIndicatorSizingCell, width: cachedTableViewWidth)
        
        return cachedTypingIndicatorCellHeight ?? 0.0
    }
    
    func heightForTypingPreviewCell(withText text: String?) -> CGFloat {
        typingPreviewSizingCell.applyStyles(styles, isReply: true)
        typingPreviewSizingCell.messageText = text
        
        return heightForStyledView(typingPreviewSizingCell, width: tableView.bounds.width)
    }
    
    func heightForCellWithEvent(_ event: Event?, isReply: Bool, listPosition: MessageListPosition, detailsVisible: Bool) -> CGFloat {
        guard let event = event else { return 0.0 }
        
        let canCacheHeight = !detailsVisible
        
        cachedTableViewWidth = tableView.bounds.width
        
        if canCacheHeight {
            if let cachedHeight = cellHeightCache[event] {
//            print("Cached Height: \(cachedHeight)")
                return cachedHeight
            }
        }
        
        // Calculate height
        let height: CGFloat = calculateHeightForCellWithEvent(event,
                                                              isReply: isReply,
                                                              listPosition: listPosition,
                                                              detailsVisible: detailsVisible,
                                                              width: cachedTableViewWidth)
        if canCacheHeight {
            cellHeightCache[event] = height
        }
        
//        print("Calculated Height: \(height)")        
        
        return height
    }
    
    fileprivate func calculateHeightForCellWithEvent(_ event: Event,
                                                 isReply: Bool,
                                                 listPosition: MessageListPosition,
                                                 detailsVisible: Bool,
                                                 width: CGFloat) -> CGFloat {
        
        // Picture Message
        if event.eventType == .pictureMessage {
            pictureMessageSizingCell.applyStyles(styles, isReply: isReply)
            pictureMessageSizingCell.listPosition = listPosition
            pictureMessageSizingCell.event = event
            return heightForStyledView(pictureMessageSizingCell, width: width)
        }
        
        // Text Message
        if event.eventType == .textMessage {
            textMessageSizingCell.applyStyles(styles, isReply: isReply)
            textMessageSizingCell.listPosition = listPosition
            textMessageSizingCell.event = event
            textMessageSizingCell.messageText = event.textMessage?.text
            textMessageSizingCell.detailLabelHidden = !detailsVisible
            return heightForStyledView(textMessageSizingCell, width: width)
        }
        
        // SRS Response
        if event.eventType == .srsResponse {
            if let srsResponse = event.srsResponse {
                switch srsResponse.displayType {
                case .Inline, .ActionSheet:
                    srsItemListViewSizingCell.applyStyles(styles, isReply: isReply)
                    srsItemListViewSizingCell.listPosition = listPosition
                    srsItemListViewSizingCell.event = event
                    srsItemListViewSizingCell.response = srsResponse
                    srsItemListViewSizingCell.detailLabelHidden = !detailsVisible
                    return heightForStyledView(srsItemListViewSizingCell, width: width)
                }
            }
        }
        
        // Info Cell
        if [EventType.crmCustomerLinked, EventType.newIssue, EventType.newRep].contains(event.eventType) {
            infoTextSizingCell.applyStyles(styles)

            switch event.eventType {
            case .crmCustomerLinked:
                infoTextSizingCell.infoText = ASAPPLocalizedString("Customer Linked")
                break
                
            case .newIssue:
                infoTextSizingCell.infoText = ASAPPLocalizedString("New Issue: \(event.newIssue?.issueId ?? 0)")
                break
                
            case .newRep:
                infoTextSizingCell.infoText = ASAPPLocalizedString("New Rep: \(event.newRep?.name ?? String(describing: event.newRep?.repId))")
                break
                
            default:  // Other cases not handled
                break
            }
            
            return heightForStyledView(infoTextSizingCell, width: width)
        }
        
        return 0.0
    }
    
    fileprivate func heightForStyledView(_ view: UIView, width: CGFloat) -> CGFloat {
        guard width > 0 else { return 0.0 }
        
        return ceil(view.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height)
    }
}
