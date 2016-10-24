//
//  ChatActionableMessageView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatActionableMessageView: UIView, ASAPPStyleable {

    class func approximateRowHeight(withStyles styles: ASAPPStyles) -> CGFloat {
        return ChatSuggestedReplyCell.approximateHeight(withFont: styles.buttonFont)
    }
    
    func setSRSResponse(srsResponse: SRSResponse?, event: Event?) {
        self.event = event
        self.srsResponse = srsResponse
    }
    
    fileprivate(set) var event: Event?
    
    fileprivate(set) var srsResponse: SRSResponse? {
        didSet {
            selectedButtonItem = nil
            buttonItems = srsResponse?.buttonItems
        }
    }
    
    fileprivate(set) var selectedButtonItem: SRSButtonItem?
    
    var onButtonItemSelection: ((SRSButtonItem) -> Void)?
    
    fileprivate(set) var buttonItems: [SRSButtonItem]? {
        didSet {
            
//            if DEMO_CONTENT_ENABLED {
//                let testButton = SRSButtonItem(title: "Restart Device", type: .Action)
//                testButton.actionName = "DeviceRestart"
//                buttonItems?.append(testButton)
//            }
            
            tableView.reloadData()
            tableView.setContentOffset(CGPoint.zero, animated: false)
            updateGradientVisibility()
        }
    }
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    fileprivate let CellReuseId = "CellReuseId"
    
    fileprivate let replySizingCell = ChatSuggestedReplyCell()
    
    fileprivate let gradientView = VerticalGradientView()
    
    // MARK: Initialization
    
    func commonInit() {
        tableView.backgroundColor = UIColor.clear
        tableView.scrollsToTop = false
        tableView.alwaysBounceVertical = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(ChatSuggestedReplyCell.self,
                                forCellReuseIdentifier: CellReuseId)
        addSubview(tableView)
        
        let gradientColor = UIColor(red: 60.0 / 255.0,
                                    green: 64.0 / 255.0,
                                    blue: 73.0 / 255.0,
                                    alpha: 1)
        gradientView.update(gradientColor.withAlphaComponent(0.0),
                            middleColor: gradientColor.withAlphaComponent(0.08),
                            bottomColor: gradientColor.withAlphaComponent(0.3))
        gradientView.isUserInteractionEnabled = false
        gradientView.alpha = 0.0
        addSubview(gradientView)
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
    
    // MARK:- ASAPPStyleable
    
    fileprivate(set) var styles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        tableView.reloadData()
    }
    
    // MARK:- Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.frame = bounds
        
        let gradientHeight: CGFloat = 30.0
        let gradientTop = bounds.height - gradientHeight
        gradientView.frame = CGRect(x: 0, y: gradientTop, width: bounds.width, height: gradientHeight)
        
        updateGradientVisibility()
    }
    
    func updateGradientVisibility() {
        if tableView.contentSize.height > tableView.bounds.height {
            
            let maxContentOffset = tableView.contentSize.height - tableView.bounds.height
            let visibilityBuffer: CGFloat = 70
            let maxVisibleGradientOffset = maxContentOffset - visibilityBuffer
            
            let offsetY = tableView.contentOffset.y
            if offsetY < maxVisibleGradientOffset {
                gradientView.alpha = 1.0
            } else if offsetY >= maxContentOffset  {
                gradientView.alpha = 0.0
            } else {
                gradientView.alpha = (maxContentOffset - offsetY) / visibilityBuffer
            }
        } else {
            gradientView.alpha = 0.0
        }
    }
}

// MARK:- UITableViewDataSource

extension ChatActionableMessageView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let buttonItems = buttonItems {
            return buttonItems.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as? ChatSuggestedReplyCell {
            styleSuggestedReplyCell(cell, atIndexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    // Mark: Utility
    
    func buttonItemForIndexPath(_ indexPath: IndexPath) -> SRSButtonItem? {
        if let buttonItems = buttonItems {
            if (indexPath as NSIndexPath).row >= 0 && (indexPath as NSIndexPath).row < buttonItems.count {
                return buttonItems[(indexPath as NSIndexPath).row]
            }
        }
        return nil
    }
    
    func styleSuggestedReplyCell(_ cell: ChatSuggestedReplyCell, atIndexPath indexPath: IndexPath) {
        cell.textLabel?.textColor = styles.buttonColor
        cell.textLabel?.font = styles.buttonFont
        cell.backgroundColor = styles.backgroundColor2
        cell.selectedBackgroundColor = styles.backgroundColor2.highlightColor()
        cell.separatorBottomColor = styles.separatorColor1
        
        if let buttonItem = buttonItemForIndexPath(indexPath) {
            cell.textLabel?.attributedText = NSAttributedString(string: buttonItem.title.uppercased(), attributes: [
                NSFontAttributeName : styles.buttonFont,
                NSForegroundColorAttributeName : styles.buttonColor,
                NSKernAttributeName : 1.5
                ])
            cell.imageTintColor = styles.buttonColor
            if ConversationManager.demo_CanOverrideButtonItemSelection(buttonItem: buttonItem) ||
                buttonItem.type == .SRS || buttonItem.type == .Action || buttonItem.type == .Message {
                cell.imageView?.isHidden = true
            } else {
                cell.imageView?.isHidden = false
            }
        } else {
            cell.textLabel?.text = nil
        }
        
        if selectedButtonItem != nil {
            if selectedButtonItem == buttonItemForIndexPath(indexPath) {
                cell.textLabel?.alpha = 1
            } else {
                cell.textLabel?.alpha = 0.3
            }
        } else {
            cell.textLabel?.alpha = 1
        }
    }
}

// MARK:- UITableViewDelegate

extension ChatActionableMessageView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        styleSuggestedReplyCell(replySizingCell, atIndexPath: indexPath)
        let height = replySizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let buttonItem = buttonItemForIndexPath(indexPath) {
            selectedButtonItem = buttonItem
            onButtonItemSelection?(buttonItem)
            
            updateCellsAnimated(animated: true)
        }
    }
    
    fileprivate func updateCellsAnimated(animated: Bool) {
        func updateBlock() {
            for cell in tableView.visibleCells {
                if let cell = cell as? ChatSuggestedReplyCell,
                    let cellIdxPath = tableView.indexPath(for: cell) {
                    self.styleSuggestedReplyCell(cell, atIndexPath: cellIdxPath)
                }
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: updateBlock)
        } else {
            updateBlock()
        }
    }
}

// MARK:- UIScrollViewDelegate

extension ChatActionableMessageView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateGradientVisibility()
    }
}

// MARK:- Instance Methods

extension ChatActionableMessageView {
    func flashScrollIndicatorsIfNecessary() {
        if tableView.contentSize.height > tableView.bounds.height + 30 {
            Dispatcher.delay(600) {
                self.tableView.flashScrollIndicators()
            }
        }
    }
    
    func deselectButtonSelection(animated: Bool) {
        if selectedButtonItem != nil {
            selectedButtonItem = nil
            updateCellsAnimated(animated: animated)
        }
    }
    
    func clearSelection() {
        selectedButtonItem = nil
        tableView.reloadData()
    }
}
