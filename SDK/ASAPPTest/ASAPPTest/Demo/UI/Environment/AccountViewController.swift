//
//  AccountViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 6/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class AccountViewController: BaseTableViewController {

    enum Section: Int {
        case name
        case image
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
        return Section.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.name.rawValue: return ""
        case Section.image.rawValue: return "Avatar Image"
        default: return nil
        }
    }
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch indexPath.section {
        case Section.image.rawValue:
            return imageViewCarouselCell(imageNames: AppSettings.shared.userImageNames,
                                         selectedImageName: AppSettings.shared.userImageName,
                                         onSelection: { (imageName) in
                                            AppSettings.saveObject(imageName, forKey: AppSettings.Key.userImageName)
            },
                                         for: indexPath,
                                         sizingOnly: forSizing)
            
        case Section.name.rawValue:
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
        
        switch indexPath.section {
        case Section.image.rawValue:
            break
            
        case Section.name.rawValue:
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
