//
//  AccountsViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol AccountsViewControllerDelegate: class {
    func accountsViewController(viewController: AccountsViewController, didSelectAccount account: UserAccount)
}

class AccountsViewController: BaseTableViewController {

    enum Section: Int {
        case current
        case create
        case all
        case count
    }
    
    // MARK: Properties
    
    var currentAccount: UserAccount? {
        didSet {
            tableView.reloadData()
        }
    }
    
    weak var delegate: AccountsViewControllerDelegate?
    
    fileprivate var allAccounts = UserAccount.allPresetAccounts()
    
    fileprivate let imageNameSizingCell = ImageNameCell()
    fileprivate let buttonSizingCell = ButtonCell()
    
    // MARK: Init
    
    required init(appSettings: AppSettings) {
        super.init(appSettings: appSettings)
        
        title = "Accounts"
        
        allAccounts = UserAccount.allPresetAccounts()
        
        tableView.register(ImageNameCell.self, forCellReuseIdentifier: ImageNameCell.reuseId)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- UITableViewDataSource

extension AccountsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.current.rawValue:
            if currentAccount != nil {
                return 1
            } else {
                return 0
            }
            
        case Section.all.rawValue:
            return allAccounts.count
            
        case Section.create.rawValue:
            return 1

        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Section.create.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseId, for: indexPath) as? ButtonCell
            styleButtonCell(cell, forIndexPath: indexPath)
            return cell ?? UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageNameCell.reuseId, for: indexPath)
        styleAccountCell(cell as? ImageNameCell, forIndexPath: indexPath)
        return cell
    }
    
    // MARK: Internal
    
    func styleButtonCell(_ cell: ButtonCell?, forIndexPath indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.appSettings = appSettings
        cell.title = "+ Create New Account"
    }
    
    func styleAccountCell(_ cell: ImageNameCell?, forIndexPath indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.appSettings = appSettings
        cell.detailText = nil
        cell.imageSize = 50
        cell.nameLabel.font = appSettings.branding.fonts.lightFont.withSize(24)
        
        switch indexPath.section {
        case Section.current.rawValue:
            cell.name = currentAccount?.name
            if let currentAccount = currentAccount {
                cell.detailText = "Company: \(currentAccount.company)\nToken: \(currentAccount.userToken)"
            } else {
                cell.detailText = nil
            }
            cell.imageName = currentAccount?.imageName
            break
            
        case Section.all.rawValue:
            let account = allAccounts[indexPath.row]
            cell.name = account.name
            cell.detailText = "Company: \(account.company)\nToken: \(account.userToken)"
            cell.imageName = account.imageName
            break
            
        default:
            break
        }
    }
}

// MARK:- UITableViewDelegate

extension AccountsViewController {
    
    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.current.rawValue:
            if currentAccount != nil {
                return "Currently signed in as:"
            } else {
                return nil
            }
            
        case Section.all.rawValue:
            return allAccounts.count > 0 ? "Select account:" : nil
            
        case Section.create.rawValue:
            return ""
            
            
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Section.create.rawValue {
            styleButtonCell(buttonSizingCell, forIndexPath: indexPath)
            let height = ceil(buttonSizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height)
            return height
        }
        
        styleAccountCell(imageNameSizingCell, forIndexPath: indexPath)
        let height = ceil(imageNameSizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height)
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == Section.create.rawValue {
            let account = UserAccount.newRandomAccount(company: appSettings.defaultCompany)
            delegate?.accountsViewController(viewController: self, didSelectAccount: account)
            return
        }
        
        var account: UserAccount?
        if indexPath.section == Section.all.rawValue {
            account = allAccounts[indexPath.row]
        } else {
            account = currentAccount
        }
        
        if let account = account {
            delegate?.accountsViewController(viewController: self, didSelectAccount: account)
        }
    }
}
