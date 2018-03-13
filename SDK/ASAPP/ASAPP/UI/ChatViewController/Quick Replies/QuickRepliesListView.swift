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
    
    var onRestartActionButtonTapped: ((_ cell: RestartActionButtonCell) -> Void)? {
        didSet {
            updateDisplay()
        }
    }
    
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
            tableView.setContentOffset(.zero, animated: false)
            updateGradientVisibility()
        }
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let replySizingCell = QuickReplyCell()
    
    private let restartActionButtonSizingCell = RestartActionButtonCell()
    
    private let gradientView = VerticalGradientView()
    
    // MARK: Initialization
    
    func commonInit() {
        tableView.backgroundColor = .clear
        tableView.scrollsToTop = false
        tableView.alwaysBounceVertical = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: QuickReplyCell.contentInset.top, left: 0, bottom: QuickReplyCell.contentInset.bottom, right: 0)
        tableView.register(QuickReplyCell.self, forCellReuseIdentifier: QuickReplyCell.reuseIdentifier)
        tableView.register(RestartActionButtonCell.self, forCellReuseIdentifier: RestartActionButtonCell.reuseIdentifier)
        addSubview(tableView)
        
        let gradientColor = UIColor(red: 60.0 / 255.0,
                                    green: 64.0 / 255.0,
                                    blue: 73.0 / 255.0,
                                    alpha: 1)
        gradientView.update(colors: [
            gradientColor.withAlphaComponent(0.0),
            gradientColor.withAlphaComponent(0.08),
            gradientColor.withAlphaComponent(0.3)
        ])
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
        } else if onRestartActionButtonTapped != nil {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if onRestartActionButtonTapped != nil,
           let cell = tableView.dequeueReusableCell(withIdentifier: RestartActionButtonCell.reuseIdentifier) as? RestartActionButtonCell {
            styleRestartActionButtonCell(cell)
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: QuickReplyCell.reuseIdentifier) as? QuickReplyCell {
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
        let quickReply = quickReplyForIndexPath(indexPath)
        let enabled = (selectedQuickReply == nil && !selectionDisabled) || selectedQuickReply == quickReply
        cell.update(for: quickReply, enabled: enabled)
        cell.layoutSubviews()
    }
    
    func styleRestartActionButtonCell(_ cell: RestartActionButtonCell) {
        cell.button.updateText(ASAPP.strings.restartActionButton, textStyle: ASAPP.styles.textStyles.actionButton, colors: ASAPP.styles.colors.actionButton)
        cell.activityIndicatorStyle = ASAPP.styles.colors.actionButton.backgroundDisabled.isDark() ? .white : .gray
        cell.layoutSubviews()
    }
}

// MARK: - UITableViewDelegate

extension QuickRepliesListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if onRestartActionButtonTapped != nil {
            styleRestartActionButtonCell(restartActionButtonSizingCell)
            return restartActionButtonSizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height
        } else {
            styleQuickReplyCell(replySizingCell, atIndexPath: indexPath)
            return replySizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard selectedQuickReply == nil && !selectionDisabled else { return }
        
        if onRestartActionButtonTapped != nil {
            if let cell = tableView.cellForRow(at: indexPath) as? RestartActionButtonCell,
               cell.button.isEnabled {
                cell.showSpinner()
                onRestartActionButtonTapped?(cell)
            }
        } else if let quickReply = quickReplyForIndexPath(indexPath),
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
                   let cellIndexPath = tableView.indexPath(for: cell) {
                    self.styleQuickReplyCell(cell, atIndexPath: cellIndexPath)
                } else if let cell = cell as? RestartActionButtonCell {
                    self.styleRestartActionButtonCell(cell)
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
