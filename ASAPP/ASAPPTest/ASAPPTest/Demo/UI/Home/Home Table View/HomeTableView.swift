//
//  HomeTableView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol HomeTableViewDelegate: class {
    func homeTableViewDidTapBillDetails(homeTableView: HomeTableView)
}

class HomeTableView: UIView {

    var appSettings: AppSettings {
        didSet {
            applyAppSettings()
        }
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            tableView.contentInset = contentInset
            tableView.scrollIndicatorInsets = contentInset
            
            tableView.contentOffset = CGPoint(x: 0, y: -contentInset.top)
        }
    }
    
    weak var delegate: HomeTableViewDelegate?
    
    // MARK: Private Properties
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    let headerSizingView = TableHeaderView()
    let nameSizingCell = HomeNameCell()
    let billSizingCell = BillSummaryCell()
    let textIconSizingCell = HomeTextIconCell()
    
    let nameCellReuseId = "NameCellReuseId"
    let billCellReuseId = "BillCellReuseId"
    let textIconCellReuseId = "TextIconCellReuseId"
    
    fileprivate enum Section: Int {
        case profile
        case bill
        case settings
        case count
    }
    
    fileprivate enum SettingsRow: Int {
        case paymentMethods
        case usage
        case messages
        case invite
        case rewards
        case notifications
        case touchId
        case privacy
        case settings
        case count
    }
    
    // MARK: Initialization
    
    required init(appSettings: AppSettings) {
        self.appSettings = appSettings
        super.init(frame: .zero)
        
        backgroundColor = UIColor.clear
        
        tableView.backgroundColor = UIColor.clear
        tableView.register(HomeNameCell.self, forCellReuseIdentifier: nameCellReuseId)
        tableView.register(BillSummaryCell.self, forCellReuseIdentifier: billCellReuseId)
        tableView.register(HomeTextIconCell.self, forCellReuseIdentifier: textIconCellReuseId)
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
        
        applyAppSettings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK: View
    
    func applyAppSettings() {
        tableView.backgroundColor = appSettings.backgroundColor2
        tableView.reloadData()
    }

    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.frame = bounds
    }
}

// MARK:- UITableViewDataSource

extension HomeTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.profile.rawValue, Section.bill.rawValue: return 1
        case Section.settings.rawValue: return SettingsRow.count.rawValue
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: TableViewCell?
        
        switch indexPath.section {
        case Section.profile.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: nameCellReuseId, for: indexPath) as? TableViewCell
            break
            
        case Section.bill.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: billCellReuseId, for: indexPath) as? TableViewCell
            break
            
        case Section.settings.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: textIconCellReuseId, for: indexPath) as? TableViewCell
            styleTextIconCell(cell: cell as? HomeTextIconCell, forRow: indexPath.row)
            break
            
        default:
            return UITableViewCell()
        }
        
        cell?.appSettings = appSettings
        
        return cell ?? UITableViewCell()
    }
    
    // MARK: Cell Style Utility
    
    func styleTextIconCell(cell: HomeTextIconCell?, forRow row: Int) {
        guard let cell = cell else { return }
        cell.appSettings = appSettings
        
        var title: String?, imageName: String?
        
        switch row {
        case SettingsRow.paymentMethods.rawValue:
            title = "Payment Accounts"
            imageName = "icon-creditcard"
            break
            
        case SettingsRow.usage.rawValue:
            title = "Usage"
            imageName = "icon-line-graph"
            break
            
        case SettingsRow.messages.rawValue:
            title = "Messages"
            imageName = "icon-chat-bubble"
            break
            
        case SettingsRow.invite.rawValue:
            title = "Refer Friends"
            imageName = "icon-users"
            break
            
        case SettingsRow.rewards.rawValue:
            title = "Rewards"
            imageName = "icon-dollar"
            break
            
        case SettingsRow.notifications.rawValue:
            title = "Notifications"
            imageName = "icon-bell"
            break
            
        case SettingsRow.touchId.rawValue:
            title = "TouchID"
            imageName = "icon-fingerprint"
            break
            
        case SettingsRow.privacy.rawValue:
            title = "Privacy"
            imageName = "icon-lock"
            break
            
        case SettingsRow.settings.rawValue:
            title = "Settings"
            imageName = "icon-gear-2"
            break

        default: // No-op
            break
        }
        cell.title = title
        if let imageName = imageName {
            cell.iconImage = UIImage(named: imageName)
        } else {
            cell.iconImage = nil
        }
    }
}

// MARK:- UITableViewDelegate

extension HomeTableView: UITableViewDelegate {
    
    // MARK: Header
    
    func titleForSection(_ section: Int) -> String? {
        var title: String?
        switch section {
        case Section.profile.rawValue:
            title = "Profile"
            break
            
        case Section.bill.rawValue:
            title = "Billing"
            break
        
        case Section.settings.rawValue:
            title = "Settings"
            break
            
        default: // No-op
            break
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TableHeaderView()
        headerView.appSettings = appSettings
        headerView.title = titleForSection(section)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerSizingView.appSettings = appSettings
        headerSizingView.title = titleForSection(section)
        let height = ceil(headerSizingView.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height)
        return height 
    }
    
    // MARK: Footer
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == Section.count.rawValue - 1 {
            return 64.0
        }
        
        return 0.0001
    }
    
    // MARK: Cells
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sizer = CGSize(width: tableView.bounds.width, height: 0)
        
        switch indexPath.section {
        case Section.profile.rawValue:
            nameSizingCell.appSettings = appSettings
            return nameSizingCell.sizeThatFits(sizer).height
            
        case Section.bill.rawValue:
            billSizingCell.appSettings = appSettings
            return billSizingCell.sizeThatFits(sizer).height
        
        case Section.settings.rawValue:
            styleTextIconCell(cell: textIconSizingCell, forRow: indexPath.row)
            return textIconSizingCell.sizeThatFits(sizer).height
            
        default: return 50.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
     
        switch indexPath.section {
        case Section.profile.rawValue:
            break
            
        case Section.bill.rawValue:
            delegate?.homeTableViewDidTapBillDetails(homeTableView: self)
            break
            
        case Section.settings.rawValue:
            break
            
        default:
            // No-op
            break
        }
    }
}
