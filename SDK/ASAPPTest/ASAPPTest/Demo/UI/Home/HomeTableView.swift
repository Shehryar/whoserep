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
    func homeTableViewDidTapRegionCode(_ homeTableView: HomeTableView)
    func homeTableViewDidTapCustomerIdentifier(_ homeTableView: HomeTableView)
    func homeTableViewDidTapAuthToken(_ homeTableView: HomeTableView)
    func homeTableViewDidTapAppearance(_ homeTableView: HomeTableView)
    
    func homeTableViewDidTapBillDetails(homeTableView: HomeTableView)
    func homeTableViewDidTapHelp(homeTableView: HomeTableView)
    func homeTableViewDidTapSwitchAccount(homeTableView: HomeTableView)
    func homeTableViewDidTapEnvironmentSettings(homeTableView: HomeTableView)
    func homeTableViewDidTapDemoComponentsUI(homeTableView: HomeTableView)
}

class HomeTableView: UIView {
    
    fileprivate enum Section: Int, CountableEnum {
        case user
        case settings
        case billing
        case other
    }
    
    fileprivate enum SettingsRow: Int, CountableEnum {
        case apiHostName
        case appId
        case regionCode
        case customerIdentifier
        case authToken
        case appearance
    }
    
    fileprivate enum OtherRow: Int, CountableEnum {
        case paymentMethods
        case usage
        case invite
        case notifications
        case help
        case touchId
        case privacy
        case settings
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

// MARK: - Header

extension HomeTableView {
    
    func headerForSection(_ section: Int, viewToStyle: TableHeaderView? = nil) -> TableHeaderView {
        var title: String?
        switch section {
        case Section.user.rawValue:
            title = ""
            
        case Section.settings.rawValue:
            title = "SETTINGS - \(AppSettings.shared.versionString)"
            
        case Section.billing.rawValue:
            title = "Billing"
            
        case Section.other.rawValue:
            title = "Other"
            
        default: // No-op
            demoLog("Missing Title for section: \(section)")
        }
        
        let headerView = viewToStyle ?? TableHeaderView()
        headerView.title = title
        
        return headerView
    }
}

// MARK: - Cells

extension HomeTableView {
    
    func getCellForRowAt(indexPath: IndexPath, forSizing: Bool = false) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .some(.user):
            return imageNameCell(cellToStyle: forSizing ? nameSizingCell : nil,
                                 name: AppSettings.shared.userName,
                                 imageName: AppSettings.shared.userImageName,
                                 for: indexPath)
            
        case .some(.settings):
            var title: String?
            var value: String?
            switch SettingsRow(rawValue: indexPath.row) {
            case .some(.apiHostName):
                title = "API Host"
                value = AppSettings.shared.apiHostName
                
            case .some(.appId):
                title = "App Id"
                value = AppSettings.shared.appId
                
            case .some(.customerIdentifier):
                title = "Customer Id"
                if let customerIdentifier = AppSettings.shared.customerIdentifier {
                    value = customerIdentifier
                } else {
                    value = "Anonymous User"
                }
                
            case .some(.authToken):
                title = "Auth Token"
                value = AppSettings.shared.authToken
                
            case .some(.regionCode):
                title = "Region Code"
                value = AppSettings.shared.regionCode
                
            case .some(.appearance):
                title = "Appearance"
                value = AppSettings.shared.appearanceConfig.name
                
            case .none:
                demoLog("Missing cell for index path: \(indexPath)")
            }
            return titleDetailValueCell(cellToStyle: forSizing ? titleDetailValueSizingCell : nil,
                                        title: title,
                                        value: value,
                                        for: indexPath)
            
        case .some(.billing):
            return titleDetailValueCell(cellToStyle: forSizing ? titleDetailValueSizingCell : nil,
                                        title: "Current Balance",
                                        detail: billDetails.dueDateString,
                                        value: billDetails.total,
                                        for: indexPath)
            
        case .some(.other):
            var title: String?, imageName: String?
            switch OtherRow(rawValue: indexPath.row) {
            case .some(.paymentMethods):
                title = "Payment Accounts"
                imageName = "icon-creditcard"
                
            case .some(.usage):
                title = "Usage"
                imageName = "icon-line-graph"
                
            case .some(.invite):
                title = "Refer Friends"
                imageName = "icon-users"
                
            case .some(.notifications):
                title = "Notifications"
                imageName = "icon-bell"
                
            case .some(.help):
                title = "Help"
                imageName = "icon-chat-bubble"
                
            case .some(.touchId):
                title = "TouchID"
                imageName = "icon-fingerprint"
                
            case .some(.privacy):
                title = "Privacy"
                imageName = "icon-lock"
                
            case .some(.settings):
                title = "Settings"
                imageName = "icon-gear-2"
                
            case .none:
                demoLog("Missing cell for indexPath: \(indexPath)")
            }
            return labelIconCell(cellToStyle: forSizing ? labelIconSizingCell : nil,
                                 title: title,
                                 imageName: imageName,
                                 for: indexPath)
            
        case .none:
            demoLog("Missing cell for indexPath: \(indexPath)")
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

// MARK: - UITableViewDataSource

extension HomeTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .some(.user): return 1
        case .some(.settings): return SettingsRow.count
        case .some(.billing): return 1
        case .some(.other): return OtherRow.count
        case .none: return 0
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

// MARK: - UITableViewDelegate

extension HomeTableView: UITableViewDelegate {
    
    // MARK: Header / Footer Heights
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerView = headerForSection(section, viewToStyle: headerSizingView)
        let height = ceil(headerView.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height)
        return height
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == Section.count - 1 {
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
     
        switch Section(rawValue: indexPath.section) {
        case .some(.user):
            delegate?.homeTableViewDidTapUserName(self)
            
        case .some(.settings):
            switch SettingsRow(rawValue: indexPath.row) {
            case .some(.appId):
                delegate?.homeTableViewDidTapAppId(self)
                
            case .some(.apiHostName):
                delegate?.homeTableViewDidTapAPIHostName(self)
                
            case .some(.regionCode):
                delegate?.homeTableViewDidTapRegionCode(self)
                
            case .some(.customerIdentifier):
                delegate?.homeTableViewDidTapCustomerIdentifier(self)
             
            case .some(.authToken):
                delegate?.homeTableViewDidTapAuthToken(self)
                
            case .some(.appearance):
                delegate?.homeTableViewDidTapAppearance(self)
                
            case .none: break
            }
            
        case .some(.billing):
            delegate?.homeTableViewDidTapBillDetails(homeTableView: self)
            
        case .some(.other):
            switch OtherRow(rawValue: indexPath.row) {
            case .some(.help):
                delegate?.homeTableViewDidTapHelp(homeTableView: self)
                
            default:
                delegate?.homeTableViewDidTapDemoComponentsUI(homeTableView: self)
            }
            
        case .none:
            delegate?.homeTableViewDidTapDemoComponentsUI(homeTableView: self)
        }
    }
}
