//
//  ChatActionableMessageView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatActionableMessageView: UIView {

    class func approximateRowHeight() -> CGFloat {
        return ChatSuggestedReplyCell.approximateHeight(withFont: ASAPP.styles.font(for: .srsButton))
    }
    
    func setSRSResponse(srsResponse: EventSRSResponse?, event: Event?) {
        self.event = event
        self.srsResponse = srsResponse
    }
    
    fileprivate(set) var event: Event?
    
    fileprivate(set) var srsResponse: EventSRSResponse? {
        didSet {
            selectedButtonItem = nil
            buttonItems = srsResponse?.buttonItems
        }
    }
    
    fileprivate(set) var selectedButtonItem: SRSButtonItem?
    
    var onButtonItemSelection: ((SRSButtonItem) -> Bool)?
    
    fileprivate(set) var buttonItems: [SRSButtonItem]? {
        didSet {            
//            if ASAPP.isDemoContentEnabled() {
//                let testButton = SRSButtonItem(title: "Restart Device", type: .Action)
//                testButton.actionEndpoint = "DeviceRestart"
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
    
    // MARK:- Display
    
    func updateDisplay() {
        tableView.reloadData()
        setNeedsLayout()
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
        cell.label.textColor = ASAPP.styles.buttonColor
        cell.label.textAlignment = .center
        cell.backgroundColor = ASAPP.styles.backgroundColor2
        cell.label.font = ASAPP.styles.font(for: .srsButton)
        cell.separatorBottomColor = ASAPP.styles.separatorColor1
        
        if let buttonItem = buttonItemForIndexPath(indexPath) {
            cell.label.setAttributedText(buttonItem.title.uppercased(),
                                         textStyle: .srsButton,
                                         color: ASAPP.styles.buttonColor)
            cell.imageTintColor = ASAPP.styles.buttonColor
            
            if ConversationManager.demo_CanOverrideButtonItemSelection(buttonItem: buttonItem) ||
                [.SRS, .Action, .Message, .AppAction].contains(buttonItem.type) {
                cell.imageView?.isHidden = true
                cell.accessibilityTraits = UIAccessibilityTraitButton
            } else {
                cell.imageView?.isHidden = false
                cell.accessibilityTraits = UIAccessibilityTraitLink
            }
        } else {
            cell.label.text = nil
        }
        
        if selectedButtonItem != nil {
            if selectedButtonItem == buttonItemForIndexPath(indexPath) {
                cell.label.alpha = 1
            } else {
                cell.label.alpha = 0.3
            }
            cell.selectedBackgroundColor = nil
        } else {
            cell.label.alpha = 1
            cell.selectedBackgroundColor = ASAPP.styles.backgroundColor2.highlightColor()
        }
        
        
        cell.layoutSubviews()
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
        
        guard selectedButtonItem == nil else { return }
        
        if let buttonItem = buttonItemForIndexPath(indexPath),
            let onButtonItemSelection = onButtonItemSelection {
            selectedButtonItem = buttonItem
            if !onButtonItemSelection(buttonItem) {
                selectedButtonItem = nil
            }
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
