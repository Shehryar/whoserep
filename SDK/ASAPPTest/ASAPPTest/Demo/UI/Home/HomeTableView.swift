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
    func homeTableViewDidTapBillDetails(homeTableView: HomeTableView)
    func homeTableViewDidTapHelp(homeTableView: HomeTableView)
    func homeTableViewDidTapSwitchAccount(homeTableView: HomeTableView)
    func homeTableViewDidTapEnvironmentSettings(homeTableView: HomeTableView)
    func homeTableViewDidTapDemoComponentsUI(homeTableView: HomeTableView)
}

class HomeTableView: UIView {

    var appSettings: AppSettings {
        didSet {
            applyAppSettings()
        }
    }
    
    var currentAccount: UserAccount? {
        didSet {
            tableView.reloadData()
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
    
    let billDetails = BillDetails()
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    let headerSizingView = TableHeaderView()
    let nameSizingCell = ImageNameCell()
    let labelIconSizingCell = LabelIconCell()
    let buttonSizingCell = ButtonCell()
    let titleDetailValueSizingCell = TitleDetailValueCell()
    
    fileprivate enum Section: Int {
        case profile
        case demoSettings
        case bill
        case settings
        case count
    }
    
    fileprivate enum ProfileRow: Int {
        case profile
        case signOut
        case count
    }
    
    fileprivate enum SettingsRow: Int {
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
    
    // MARK: Initialization
    
    required init(appSettings: AppSettings) {
        self.appSettings = appSettings
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
        tableView.backgroundColor = appSettings.branding.colors.secondaryBackgroundColor
        tableView.separatorColor = appSettings.branding.colors.separatorColor
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

// MARK:- UITableViewDataSource

extension HomeTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.profile.rawValue: return ProfileRow.count.rawValue
        case Section.demoSettings.rawValue: return 1
        case Section.bill.rawValue: return 1
        case Section.settings.rawValue: return SettingsRow.count.rawValue
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: TableViewCell?
        
        switch indexPath.section {
        //
        // Profile
        //
        case Section.profile.rawValue:
            switch indexPath.row {
            case ProfileRow.profile.rawValue:
                cell = tableView.dequeueReusableCell(withIdentifier: ImageNameCell.reuseId, for: indexPath) as? TableViewCell
                styleUserAccountCell(cell as? ImageNameCell, forIndexPath: indexPath)
                break
                
            case ProfileRow.signOut.rawValue:
                cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseId, for: indexPath) as? ButtonCell
                styleButtonCell(cell: cell as? ButtonCell, forIndexPath: indexPath)
                break
            
            default:
                DemoLog("Missing cell for indexPath: \(indexPath)")
                break
            }
            break
         
    
        //
        // Demo Settings, Bill Summary
        //
        case Section.demoSettings.rawValue, Section.bill.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: TitleDetailValueCell.reuseId, for: indexPath) as? TableViewCell
            styleTitleDetailValueCell(cell as? TitleDetailValueCell, forIndexPath: indexPath)
            break
            
        //
        // Settings
        //
        case Section.settings.rawValue:
            cell = tableView.dequeueReusableCell(withIdentifier: LabelIconCell.reuseId, for: indexPath) as? LabelIconCell
            styleLabelIconCell(cell: cell as? LabelIconCell, forRow: indexPath.row)
            break
            
        default:
            DemoLog("Missing cell for indexPath: \(indexPath)")
            break
        }
        
        return cell ?? TableViewCell()
    }
    
    // MARK: Cell Style Utility
    
    func styleTitleDetailValueCell(_ cell: TitleDetailValueCell?, forIndexPath indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.appSettings = appSettings
        cell.selectionStyle = .default
        
        switch indexPath.section {
        case Section.demoSettings.rawValue:
            var featuresString: String
            if ASAPP.isDemoContentEnabled() {
                featuresString = "DEMO CONTENT ENABLED"
            } else {
                featuresString = "Default Configuration"
            }
            cell.update(titleText: "API Host:",
                        detailText: featuresString,
                        valueText: "\(appSettings.apiHostName)")
            break
        
        case Section.bill.rawValue:
            cell.update(titleText: "Current Balance",
                        detailText: billDetails.dueDateString,
                        valueText: billDetails.total)
            break
            
        default:
            break
        }
    }
    
    func styleUserAccountCell(_ cell: ImageNameCell?, forIndexPath indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.selectionStyle = .none
        cell.appSettings = appSettings
        cell.name = currentAccount?.name ?? "Sign In"
        if let currentAccount = currentAccount {
            cell.detailText = "Company: \(currentAccount.company)\nToken: \(currentAccount.userToken)"
        } else {
            cell.detailText = nil
        }
        cell.imageName = currentAccount?.imageName
    }
    
    func styleButtonCell(cell: ButtonCell?, forIndexPath indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.appSettings = appSettings
        cell.titleAlignment = .left
        
        switch indexPath.section {
        case Section.profile.rawValue:
            switch indexPath.row {
            case ProfileRow.signOut.rawValue:
                cell.title = "Switch Account"
                break
                
            default:
                break
            }
            break
            
        default:
            break
        }
    }
    
    func styleLabelIconCell(cell: LabelIconCell?, forRow row: Int) {
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
            
//        case SettingsRow.messages.rawValue:
//            title = "Messages"
//            imageName = "icon-chat-bubble"
//            break
            
        case SettingsRow.invite.rawValue:
            title = "Refer Friends"
            imageName = "icon-users"
            break
            
//        case SettingsRow.rewards.rawValue:
//            title = "Rewards"
//            imageName = "icon-dollar"
//            break
            
        case SettingsRow.notifications.rawValue:
            title = "Notifications"
            imageName = "icon-bell"
            break
            
        case SettingsRow.help.rawValue:
            title = "Help"
            imageName = "icon-chat-bubble"
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
            
        case Section.demoSettings.rawValue:
            title = "DEMO SETTINGS - \(appSettings.versionString)"
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
            switch indexPath.row {
            case ProfileRow.profile.rawValue:
                styleUserAccountCell(nameSizingCell, forIndexPath: indexPath)
                return nameSizingCell.sizeThatFits(sizer).height
                
            case ProfileRow.signOut.rawValue:
                styleButtonCell(cell: buttonSizingCell, forIndexPath: indexPath)
                return buttonSizingCell.sizeThatFits(sizer).height
                
            default:
                return 0
            }
            
        case Section.demoSettings.rawValue, Section.bill.rawValue:
            styleTitleDetailValueCell(titleDetailValueSizingCell, forIndexPath: indexPath)
            return titleDetailValueSizingCell.sizeThatFits(sizer).height
        
        case Section.settings.rawValue:
            styleLabelIconCell(cell: labelIconSizingCell, forRow: indexPath.row)
            return labelIconSizingCell.sizeThatFits(sizer).height
            
        default: return 50.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
     
        switch indexPath.section {
        case Section.profile.rawValue:
            switch indexPath.row {
            case ProfileRow.signOut.rawValue:
                delegate?.homeTableViewDidTapSwitchAccount(homeTableView: self)
                break
                
            default:
                break
            }
            break
            
        case Section.demoSettings.rawValue:
            delegate?.homeTableViewDidTapEnvironmentSettings(homeTableView: self)
            break
            
        case Section.bill.rawValue:
            delegate?.homeTableViewDidTapBillDetails(homeTableView: self)
            break
            
        case Section.settings.rawValue:
            switch indexPath.row {
            case SettingsRow.help.rawValue:
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
