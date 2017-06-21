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
    fileprivate let imageNameSizingCell = ImageNameCell()
    fileprivate let labelIconSizingCell = LabelIconCell()
    fileprivate let titleDetailValueSizingCell = TitleDetailValueCell()
    fileprivate let titleCheckmarkSizingCell = TitleCheckmarkCell()
    fileprivate let buttonSizingCell = ButtonCell()
    
    // MARK:- Initialization
    
    override func commonInit() {
        super.commonInit()
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(ImageNameCell.self, forCellReuseIdentifier: ImageNameCell.reuseId)
        tableView.register(LabelIconCell.self, forCellReuseIdentifier: LabelIconCell.reuseId)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseId)
        tableView.register(TitleDetailValueCell.self, forCellReuseIdentifier: TitleDetailValueCell.reuseId)
        tableView.register(TitleCheckmarkCell.self, forCellReuseIdentifier: TitleCheckmarkCell.reuseId)
        tableView.backgroundColor = AppSettings.shared.branding.colors.secondaryBackgroundColor
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: Deinit
    
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
        
        tableView.backgroundColor = AppSettings.shared.branding.colors.secondaryBackgroundColor
        tableView.separatorColor = AppSettings.shared.branding.colors.separatorColor
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
        cell.textLabel?.font = AppSettings.shared.branding.fonts.boldFont.withSize(16)
        cell.textLabel?.textColor = UIColor.darkGray
        
        cell.detailTextLabel?.text = detailText
        cell.detailTextLabel?.font = AppSettings.shared.branding.fonts.regularFont.withSize(16)
        cell.detailTextLabel?.textColor = UIColor.gray
        
        cell.accessoryType = accessoryType
        
        return cell
    }
    
    func imageNameCell(name: String,
                       imageName: String,
                       for indexPath: IndexPath,
                       sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? imageNameSizingCell
            : tableView.dequeueReusableCell(withIdentifier: ImageNameCell.reuseId, for: indexPath) as? ImageNameCell
        
        cell?.appSettings = AppSettings.shared
        cell?.selectionStyle = .default
        cell?.name = name
        cell?.imageName = imageName
        
        return cell ?? UITableViewCell()
    }
    
    func titleDetailValueCell(title: String? = nil,
                              detail: String? = nil,
                              value: String? = nil,
                              for indexPath: IndexPath,
                              sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? titleDetailValueSizingCell
            : tableView.dequeueReusableCell(withIdentifier: TitleDetailValueCell.reuseId, for: indexPath) as? TitleDetailValueCell
        
        cell?.appSettings = AppSettings.shared
        cell?.selectionStyle = .default
        cell?.update(titleText: title, detailText: detail, valueText: value)
        
        return cell ?? UITableViewCell()
    }
    
    func labelIconCell(title: String?,
                       imageName: String?,
                       for indexPath: IndexPath,
                       sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? labelIconSizingCell
            : tableView.dequeueReusableCell(withIdentifier: LabelIconCell.reuseId, for: indexPath) as? LabelIconCell
        
        cell?.appSettings = AppSettings.shared
        cell?.selectionStyle = .default
        cell?.title = title
        if let imageName = imageName {
            cell?.iconImage = UIImage(named: imageName)
        } else {
            cell?.iconImage = nil
        }
        
        return cell ?? UITableViewCell()
    }
    
    func titleCheckMarkCell(title: String?,
                            isChecked: Bool,
                            for indexPath: IndexPath,
                            sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? titleCheckmarkSizingCell
            : tableView.dequeueReusableCell(withIdentifier: TitleCheckmarkCell.reuseId, for: indexPath) as? TitleCheckmarkCell
        
        cell?.appSettings = AppSettings.shared
        cell?.title = title
        cell?.isChecked = isChecked
        
        return cell ?? UITableViewCell()
    }
    
    func buttonCell(title: String?,
                    for indexPath: IndexPath,
                    sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? buttonSizingCell
            : tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseId, for: indexPath) as? ButtonCell
        
        cell?.title = title
        
        return cell ?? UITableViewCell()
    }
    
    // MARK: OVERRIDE THIS METHOD
    
    func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        fatalError("Subclass must override tableView:cellForRowAt:")
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
        return getCellForIndexPath(indexPath, forSizing: false)
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
            headerView.title = title
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let title = titleForSection(section) {
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
        let cell = getCellForIndexPath(indexPath, forSizing: true)
        return ceil(cell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // No-op
    }
}


