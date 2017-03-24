//
//  TableView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TableView: BaseComponentView {

    let tableView = UITableView(frame: .zero, style: .plain)
    
    let cellReuseId = "CellReuseId"
    
    var sizingCell: TableViewCell!
    
    let headerSizingView = TableViewSectionHeaderView()
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var tableViewItem: TableViewItem? {
        return component as? TableViewItem
    }
    
    override weak var interactionHandler: InteractionHandler? {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        sizingCell = TableViewCell(style: .default, reuseIdentifier: cellReuseId)
        
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .singleLine
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(TableViewCell.self, forCellReuseIdentifier: cellReuseId)
        addSubview(tableView)
    }
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margin = tableViewItem?.style.margin ?? .zero
        let padding = tableViewItem?.style.padding ?? .zero
        tableView.frame =  UIEdgeInsetsInsetRect(UIEdgeInsetsInsetRect(bounds, margin), padding)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // TableView always fills its parent
        return size
    }
}

// MARK:- Data Utility

extension TableView {
    
    func getSection(_ section: Int) -> TableViewSectionItem? {
        if let sections = tableViewItem?.sections,
            section < sections.count && section >= 0 {
            return sections[section]
        }
        return nil
    }
    
    func getRow(_ indexPath: IndexPath) -> Component? {
        if let section = getSection(indexPath.section),
            indexPath.row < section.rows.count && indexPath.row >= 0 {
            return section.rows[indexPath.row]
        }
        return nil
    }
    
    func getSectionHeader(_ section: Int) -> Component? {
        return getSection(section)?.header
    }
}

// MARK:- UITableViewDataSource

extension TableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewItem?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSection(section)?.rows.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = getSectionHeader(section) {
            let headerView = TableViewSectionHeaderView()
            headerView.component = header
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath) as? TableViewCell
        cell?.component = getRow(indexPath)
        cell?.interactionHandler = interactionHandler
        return cell ?? UITableViewCell(style: .default, reuseIdentifier: "hello")
    }
}

// MARK:- UITableViewDelegate

extension TableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let header = getSectionHeader(section) else {
            return 0
        }
        headerSizingView.component = header
        let maxWidth = tableView.bounds.width
        let maxHeight = CGFloat.greatestFiniteMagnitude
        let height = ceil(headerSizingView.sizeThatFits(CGSize(width: maxWidth, height: maxHeight)).height)
        
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        sizingCell.component = getRow(indexPath)
        let maxWidth = tableView.bounds.width
        let maxHeight = CGFloat.greatestFiniteMagnitude
        let height = ceil(sizingCell.sizeThatFits(CGSize(width: maxWidth, height: maxHeight)).height)
        
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
