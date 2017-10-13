//
//  QuickRepliesListView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class QuickRepliesListView: UIView {

    var onQuickReplySelected: ((QuickReply) -> Bool)?
    
    var message: ChatMessage? {
        didSet {
            selectedQuickReply = nil
            quickReplies = message?.quickReplies
        }
    }
    
    var selectionDisabled: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    private(set) var selectedQuickReply: QuickReply?
    
    private(set) var quickReplies: [QuickReply]? {
        didSet {
            selectionDisabled = false
            tableView.reloadData()
            tableView.setContentOffset(CGPoint.zero, animated: false)
            updateGradientVisibility()
        }
    }
    
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    private let cellReuseId = "CellReuseId"
    
    private let replySizingCell = QuickReplyCell()
    
    private let gradientView = VerticalGradientView()
    
    // MARK: Initialization
    
    func commonInit() {
        tableView.backgroundColor = UIColor.clear
        tableView.scrollsToTop = false
        tableView.alwaysBounceVertical = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(QuickReplyCell.self, forCellReuseIdentifier: cellReuseId)
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
    
    // MARK: - Display
    
    func updateDisplay() {
        tableView.reloadData()
        setNeedsLayout()
    }
    
    // MARK: - Layout
    
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
            } else if offsetY >= maxContentOffset {
                gradientView.alpha = 0.0
            } else {
                gradientView.alpha = (maxContentOffset - offsetY) / visibilityBuffer
            }
        } else {
            gradientView.alpha = 0.0
        }
    }
}

// MARK: - UITableViewDataSource

extension QuickRepliesListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let quickReplies = quickReplies {
            return quickReplies.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId) as? QuickReplyCell {
            styleQuickReplyCell(cell, atIndexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    // Mark: Utility
    
    func quickReplyForIndexPath(_ indexPath: IndexPath) -> QuickReply? {
        guard let quickReplies = quickReplies,
            indexPath.row >= 0 && indexPath.row < quickReplies.count else {
                return nil
        }
        return quickReplies[indexPath.row]
    }
    
    func styleQuickReplyCell(_ cell: QuickReplyCell, atIndexPath indexPath: IndexPath) {
        
        cell.label.textAlignment = .center
        cell.label.textColor = ASAPP.styles.colors.quickReplyButton.textNormal
        cell.backgroundColor = ASAPP.styles.colors.quickReplyButton.backgroundNormal
        
        cell.label.font = ASAPP.styles.textStyles.body.font
        cell.separatorBottomColor = ASAPP.styles.colors.separatorSecondary
        
        if let quickReply = quickReplyForIndexPath(indexPath) {
            
            if quickReply.action.type == .componentView {
                cell.label.setAttributedText(quickReply.title,
                                             textType: .bodyBold,
                                             color: ASAPP.styles.colors.quickReplyButton.textNormal)
            } else {
                cell.label.setAttributedText(quickReply.title,
                                             textType: .body,
                                             color: ASAPP.styles.colors.quickReplyButton.textNormal)
            }
            
            cell.imageTintColor = ASAPP.styles.colors.quickReplyButton.textNormal
            
            if quickReply.action.willExitASAPP {
                cell.imageView?.isHidden = false
                cell.accessibilityTraits = UIAccessibilityTraitLink
            } else {
                cell.imageView?.isHidden = true
                cell.accessibilityTraits = UIAccessibilityTraitButton
            }
        } else {
            cell.label.text = nil
        }
        
        if selectedQuickReply != nil || selectionDisabled {
            if selectedQuickReply == quickReplyForIndexPath(indexPath) {
                cell.label.alpha = 1
            } else {
                cell.label.alpha = 0.3
            }
            cell.selectedBackgroundColor = nil
        } else {
            cell.label.alpha = 1
            cell.selectedBackgroundColor = ASAPP.styles.colors.quickReplyButton.backgroundHighlighted
        }
        
        cell.layoutSubviews()
    }
}

// MARK: - UITableViewDelegate

extension QuickRepliesListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        styleQuickReplyCell(replySizingCell, atIndexPath: indexPath)
        let height = replySizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard selectedQuickReply == nil && !selectionDisabled else { return }
        
        if let quickReply = quickReplyForIndexPath(indexPath),
            let onQuickReplySelected = onQuickReplySelected {
            selectedQuickReply = quickReply
            if !onQuickReplySelected(quickReply) {
                selectedQuickReply = nil
            }
            updateCellsAnimated(animated: true)
        }
    }
    
    private func updateCellsAnimated(animated: Bool) {
        func updateBlock() {
            for cell in tableView.visibleCells {
                if let cell = cell as? QuickReplyCell,
                    let cellIdxPath = tableView.indexPath(for: cell) {
                    self.styleQuickReplyCell(cell, atIndexPath: cellIdxPath)
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

// MARK: - UIScrollViewDelegate

extension QuickRepliesListView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateGradientVisibility()
    }
}

// MARK: - Public Methods

extension QuickRepliesListView {
    
    func flashScrollIndicatorsIfNecessary() {
        if tableView.contentSize.height > tableView.bounds.height + 30 {
            Dispatcher.delay(600) {
                self.tableView.flashScrollIndicators()
            }
        }
    }
    
    func deselectButtonSelection(animated: Bool) {
        if selectedQuickReply != nil {
            selectedQuickReply = nil
            updateCellsAnimated(animated: animated)
        }
    }
    
    func clearSelection() {
        selectedQuickReply = nil
        selectionDisabled = false
        tableView.reloadData()
    }
    
    class func approximateRowHeight() -> CGFloat {
        return QuickReplyCell.approximateHeight(withFont: ASAPP.styles.textStyles.body.font)
    }
}
