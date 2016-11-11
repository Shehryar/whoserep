//
//  BaseTableViewController.swift
//  Analytics
//
//  Created by Mitchell Morgan on 10/19/16.
//  Copyright © 2016 ASAPP, Inc. All rights reserved.
//

import UIKit

class BaseTableViewController: BaseViewController {
    
    // MARK:- Properties
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK:- Private Properties
    
    fileprivate let headerSizingView = TableHeaderView()

    // MARK:- Initialization
    
    required init(appSettings: AppSettings) {
        super.init(appSettings: appSettings)
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.backgroundColor = appSettings.backgroundColor2
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
    }
    
    // MARK:- Updates
    
    override func reloadViewForUpdatedSettings() {
        super.reloadViewForUpdatedSettings()
        
        tableView.backgroundColor = appSettings.backgroundColor2
        tableView.separatorColor = appSettings.separatorColor
        tableView.reloadData()
    }
    
    // MARK:- Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var insetTop: CGFloat = 0.0
        if let navBar = navigationController?.navigationBar {
            insetTop = navBar.frame.maxY
        }
        
        tableView.frame = view.bounds
        tableView.contentInset = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableView.contentInset.top)
    }
}

// MARK:- UITableViewCell Helpers

extension BaseTableViewController {
    
    func textCell(forIndexPath indexPath: IndexPath, title: String?,
                  detailText: String? = nil,
                  accessoryType: UITableViewCellAccessoryType = .none) -> UITableViewCell {
        let textCellReuseId = "TextCellReuseId"
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellReuseId) ?? UITableViewCell(style: .value1, reuseIdentifier: textCellReuseId)
        
        cell.textLabel?.text = title
        cell.textLabel?.font = appSettings.boldFont.withSize(16)
        cell.textLabel?.textColor = UIColor.darkGray
        
        cell.detailTextLabel?.text = detailText
        cell.detailTextLabel?.font = appSettings.regularFont.withSize(16)
        cell.detailTextLabel?.textColor = UIColor.gray
        
        cell.accessoryType = accessoryType
        
        return cell
    }
}

// MARK:- UITableViewDataSource

extension BaseTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Subclass must override tableView:cellForRowAt:")
    }
}

// MARK:- UITableViewDelegate

extension BaseTableViewController: UITableViewDelegate {
    
    // MARK: Internal
    
    func titleForSection(_ section: Int) -> String? {
        return nil
    }
    
    // MARK: Header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = titleForSection(section) {
            let headerView = TableHeaderView()
            headerView.appSettings = appSettings
            headerView.title = title
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let title = titleForSection(section) {
            headerSizingView.appSettings = appSettings
            headerSizingView.title = title
            return headerSizingView.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height
        }
        return 0.00001
    }
    
    // MARK: Footers
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == numberOfSections(in: tableView) - 1 {
            return 64.0
        }
        return 0.00001
    }
    
    // MARK: Rows
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // No-op
    }
}


