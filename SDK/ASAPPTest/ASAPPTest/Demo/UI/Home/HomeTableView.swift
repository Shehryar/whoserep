//
//  HomeTableView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

protocol HomeTableViewDelegate: class {
    func homeTableViewDidTapUserName(_ homeTableView: HomeTableView)
    func homeTableViewDidTapAppId(_ homeTableView: HomeTableView)
    func homeTableViewDidTapAPIHostName(_ homeTableView: HomeTableView)
    func homeTableViewDidTapCustomerIdentifier(_ homeTableView: HomeTableView)
    
    func homeTableViewDidTapBillDetails(homeTableView: HomeTableView)
    func homeTableViewDidTapHelp(homeTableView: HomeTableView)
    func homeTableViewDidTapSwitchAccount(homeTableView: HomeTableView)
    func homeTableViewDidTapEnvironmentSettings(homeTableView: HomeTableView)
    func homeTableViewDidTapDemoComponentsUI(homeTableView: HomeTableView)
}

class HomeTableView: UIView {
    
    fileprivate enum Section: Int {
        case user
        case settings
        case billing
        case other
        case count
    }
    
    fileprivate enum SettingsRow: Int {
        case apiHostName
        case appId
        case customerIdentifier
        case count
    }
    
    fileprivate enum OtherRow: Int {
        case paymentMethods
        case usage
        case invite
        case notifications
        case help
        case touchId
        case privacy
        case settings
        case count
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
    
    let billDetails = BillDetails()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    let headerSizingView = TableHeaderView()
    let nameSizingCell = ImageNameCell()
    let labelIconSizingCell = LabelIconCell()
    let titleDetailValueSizingCell = TitleDetailValueCell()
    
    // MARK: Initialization
    
    required init() {
        super.init(frame: .zero)
        
        backgroundColor = UIColor.clear
        
        tableView.backgroundColor = UIColor.clear
        tableView.register(ImageNameCell.self, forCellReuseIdentifier: ImageNameCell.reuseId)
        tableView.register(LabelIconCell.self, forCellReuseIdentifier: LabelIconCell.reuseId)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseId)
        tableView.register(TitleDetailValueCell.self, forCellReuseIdentifier: TitleDetailValueCell.reuseId)
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
        tableView.backgroundColor = AppSettings.shared.branding.colors.secondaryBackgroundColor
        tableView.separatorColor = AppSettings.shared.branding.colors.separatorColor
        tableView.reloadData()
    }
    
    func reloadData() {
        tableView.reloadData()
    }

    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.frame = bounds
    }
}

// MARK:- Header

extension HomeTableView {
    
    func headerForSection(_ section: Int, viewToStyle: TableHeaderView? = nil) -> TableHeaderView {
        var title: String?
        switch section {
        case Section.user.rawValue:
            title = "User"
            break
            
        case Section.settings.rawValue:
            title = "SETTINGS - \(AppSettings.shared.versionString)"
            break
            
        case Section.billing.rawValue:
            title = "Billing"
            break
            
        case Section.other.rawValue:
            title = "Other"
            break
            
        default: // No-op
            DemoLog("Missing Title for section: \(section)")
            break
        }
        
        let headerView = viewToStyle ?? TableHeaderView()
        headerView.title = title
        
        return headerView
    }
}

// MARK:- Cells

extension HomeTableView {
    
    func getCellForRowAt(indexPath: IndexPath, forSizing: Bool = false) -> UITableViewCell {
        switch indexPath.section {
            /** User **/
        case Section.user.rawValue:
            return imageNameCell(cellToStyle: forSizing ? nameSizingCell : nil,
                                 name: AppSettings.shared.userName,
                                 imageName: AppSettings.shared.userImageName,
                                 for: indexPath)
            
            /** Settings **/
        case Section.settings.rawValue:
            var title: String?
            var value: String?
            switch indexPath.row {
            case SettingsRow.apiHostName.rawValue:
                title = "API Host Name"
                value = AppSettings.shared.apiHostName
                break
                
            case SettingsRow.appId.rawValue:
                title = "App Id"
                value = AppSettings.shared.appId
                break
                
            case SettingsRow.customerIdentifier.rawValue:
                title = "Customer Identifier"
                value = AppSettings.shared.customerIdentifier
                break
                
            default:
                DemoLog("Missing cell for index path: \(indexPath)")
                break
            }
            return titleDetailValueCell(cellToStyle: forSizing ? titleDetailValueSizingCell : nil,
                                        title: title,
                                        value: value,
                                        for: indexPath)
            
            /** Billing **/
        case Section.billing.rawValue:
            return titleDetailValueCell(cellToStyle: forSizing ? titleDetailValueSizingCell : nil,
                                        title: "Current Balance",
                                        detail: billDetails.dueDateString,
                                        value: billDetails.total,
                                        for: indexPath)
            
            /** Other **/
        case Section.other.rawValue:
            var title: String?, imageName: String?
            switch indexPath.row {
            case OtherRow.paymentMethods.rawValue:
                title = "Payment Accounts"
                imageName = "icon-creditcard"
                break
                
            case OtherRow.usage.rawValue:
                title = "Usage"
                imageName = "icon-line-graph"
                break
                
            case OtherRow.invite.rawValue:
                title = "Refer Friends"
                imageName = "icon-users"
                break
                
            case OtherRow.notifications.rawValue:
                title = "Notifications"
                imageName = "icon-bell"
                break
                
            case OtherRow.help.rawValue:
                title = "Help"
                imageName = "icon-chat-bubble"
                break
                
            case OtherRow.touchId.rawValue:
                title = "TouchID"
                imageName = "icon-fingerprint"
                break
                
            case OtherRow.privacy.rawValue:
                title = "Privacy"
                imageName = "icon-lock"
                break
                
            case OtherRow.settings.rawValue:
                title = "Settings"
                imageName = "icon-gear-2"
                break
                
            default:
                DemoLog("Missing cell for indexPath: \(indexPath)")
                break
            }
            return labelIconCell(cellToStyle: forSizing ? labelIconSizingCell : nil,
                                 title: title,
                                 imageName: imageName,
                                 for: indexPath)
            
        default:
            DemoLog("Missing cell for indexPath: \(indexPath)")
            break
        }
        
        return UITableViewCell()
    }
    
    func imageNameCell(cellToStyle: ImageNameCell? = nil,
                       name: String,
                       imageName: String,
                       for indexPath: IndexPath) -> UITableViewCell {
        let cell = cellToStyle
            ?? tableView.dequeueReusableCell(withIdentifier: ImageNameCell.reuseId, for: indexPath) as? ImageNameCell
        
        cell?.appSettings = AppSettings.shared
        cell?.selectionStyle = .default
        cell?.name = name
        cell?.imageName = imageName
        
        return cell ?? UITableViewCell()
    }
    
    func titleDetailValueCell(cellToStyle: TitleDetailValueCell? = nil,
                              title: String? = nil,
                              detail: String? = nil,
                              value: String? = nil,
                              for indexPath: IndexPath) -> UITableViewCell {
        let cell = cellToStyle
            ?? tableView.dequeueReusableCell(withIdentifier: TitleDetailValueCell.reuseId, for: indexPath) as? TitleDetailValueCell
        
        cell?.appSettings = AppSettings.shared
        cell?.selectionStyle = .default
        cell?.update(titleText: title, detailText: detail, valueText: value)
        
        return cell ?? UITableViewCell()
    }
    
    func labelIconCell(cellToStyle: LabelIconCell? = nil,
                       title: String?,
                       imageName: String?,
                       for indexPath: IndexPath) -> UITableViewCell {
        let cell = cellToStyle
            ?? tableView.dequeueReusableCell(withIdentifier: LabelIconCell.reuseId, for: indexPath) as? LabelIconCell
        
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
}

// MARK:- UITableViewDataSource

extension HomeTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.user.rawValue: return 1
        case Section.settings.rawValue: return SettingsRow.count.rawValue
        case Section.billing.rawValue: return 1
        case Section.other.rawValue: return OtherRow.count.rawValue
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerForSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCellForRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK:- UITableViewDelegate

extension HomeTableView: UITableViewDelegate {
    
    // MARK: Header / Footer Heights
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerView = headerForSection(section, viewToStyle: headerSizingView)
        let height = ceil(headerView.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height)
        return height
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == Section.count.rawValue - 1 {
            return 64.0
        }
        
        return 0.0001
    }
    
    // MARK: Cell Height
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard tableView.bounds.width > 0  else {
            return 0
        }
        
        let cell = getCellForRowAt(indexPath: indexPath, forSizing: true)
        return ceil(cell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height)
    }
    
    // MARK: Cell Selection
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
     
        switch indexPath.section {
        case Section.user.rawValue:
            
            break
            
        case Section.settings.rawValue:
            switch indexPath.row {
            case SettingsRow.appId.rawValue:
                delegate?.homeTableViewDidTapAppId(self)
                break
                
            case SettingsRow.apiHostName.rawValue:
                delegate?.homeTableViewDidTapAPIHostName(self)
                break
                
            case SettingsRow.customerIdentifier.rawValue:
                delegate?.homeTableViewDidTapCustomerIdentifier(self)
                break
             
            default:
                // No-op
                break
            }
            break
            
        case Section.billing.rawValue:
            delegate?.homeTableViewDidTapBillDetails(homeTableView: self)
            break
            
        case Section.other.rawValue:
            switch indexPath.row {
            case OtherRow.help.rawValue:
                delegate?.homeTableViewDidTapHelp(homeTableView: self)
                break
                
            default:
                delegate?.homeTableViewDidTapDemoComponentsUI(homeTableView: self)
                break
            }
            break
            
        default:
            delegate?.homeTableViewDidTapDemoComponentsUI(homeTableView: self)
            break
        }
    }
}
