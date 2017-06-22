//
//  AccountViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 6/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class AccountViewController: BaseTableViewController {

    enum Row: Int {
        case image
        case name
        case count
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        title = "Account"
    }
}

// MARK:- TableView

extension AccountViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.count.rawValue
    }
    
    override func titleForSection(_ section: Int) -> String? {
        return ""
    }
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch indexPath.row {
        case Row.image.rawValue:
            return titleDetailValueCell(title: "Image",
                                        value: AppSettings.shared.userImageName,
                                        for: indexPath,
                                        sizingOnly: forSizing)
            
        case Row.name.rawValue:
            return titleDetailValueCell(title: "Name",
                                        value: AppSettings.shared.userName,
                                        for: indexPath,
                                        sizingOnly: forSizing)
            
        default: break
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case Row.image.rawValue:
            break
            
        case Row.name.rawValue:
            let viewController = TextInputViewController()
            viewController.title = "Set Name"
            viewController.instructionText = "Enter a Name"
            viewController.onFinish = { [weak self] (text) in
                guard !text.isEmpty, let strongSelf = self else {
                        return
                }
                
                AppSettings.saveObject(text, forKey: AppSettings.Key.userName)
                strongSelf.tableView.reloadData()
                strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
            }
            navigationController?.pushViewController(viewController, animated: true)
            break
            
        default: break
        }
    }
}
