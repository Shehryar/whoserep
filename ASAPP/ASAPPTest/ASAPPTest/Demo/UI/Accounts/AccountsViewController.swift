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
    
    fileprivate let allAccounts = UserAccount.all
    
    fileprivate let imageNameSizingCell = ImageNameCell()
    
    // MARK: Init
    
    required init(appSettings: AppSettings) {
        super.init(appSettings: appSettings)
        
        title = "Accounts"
        
        tableView.register(ImageNameCell.self, forCellReuseIdentifier: ImageNameCell.reuseId)
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

        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageNameCell.reuseId, for: indexPath)
        styleCell(cell as? ImageNameCell, forIndexPath: indexPath)
        return cell
    }
    
    // MARK: Internal
    
    func styleCell(_ cell: ImageNameCell?, forIndexPath indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.appSettings = appSettings
        cell.detailText = nil
        
        switch indexPath.section {
        case Section.current.rawValue:
            cell.name = currentAccount?.name
            cell.imageName = currentAccount?.imageName
            break
            
        case Section.all.rawValue:
            let account = allAccounts[indexPath.row]
            cell.name = account.name
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
            return "Select account:"
            
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        styleCell(imageNameSizingCell, forIndexPath: indexPath)
        let height = ceil(imageNameSizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height)
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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
