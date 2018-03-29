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
    
    var contentInsetBottom: CGFloat = 0 {
        didSet {
            tableView.contentInset.bottom = contentInsetBottom
            let scrollInsets = tableView.scrollIndicatorInsets
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: scrollInsets.top, left: scrollInsets.left, bottom: contentInsetBottom, right: scrollInsets.right)
        }
    }
    
    var contentHeight: CGFloat {
        return tableView.contentSize.height
    }
    
    private(set) var selectedQuickReply: QuickReply?
    
    private(set) var quickReplies: [QuickReply]? {
        didSet {
            selectionDisabled = false
            tableView.reloadData()
            tableView.setContentOffset(.zero, animated: false)
        }
    }
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let replySizingCell = QuickReplyCell()
    
    // MARK: Initialization
    
    func commonInit() {
        tableView.backgroundColor = .clear
        tableView.scrollsToTop = false
        tableView.alwaysBounceVertical = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: QuickReplyCell.contentInset.top * 3 - 1, left: 0, bottom: QuickReplyCell.contentInset.bottom * 2, right: 0)
        tableView.register(QuickReplyCell.self, forCellReuseIdentifier: QuickReplyCell.reuseIdentifier)
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
    
    // MARK: - Display
    
    func updateDisplay() {
        tableView.reloadData()
        setNeedsLayout()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.frame = bounds
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: QuickReplyCell.reuseIdentifier) as? QuickReplyCell {
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
}

// MARK: - UITableViewDelegate

extension QuickRepliesListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        styleQuickReplyCell(replySizingCell, atIndexPath: indexPath)
        return replySizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height
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
                   let cellIndexPath = tableView.indexPath(for: cell) {
                    self.styleQuickReplyCell(cell, atIndexPath: cellIndexPath)
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
        return QuickReplyCell.approximateHeight(with: ASAPP.styles.textStyles.body.font)
    }
}
