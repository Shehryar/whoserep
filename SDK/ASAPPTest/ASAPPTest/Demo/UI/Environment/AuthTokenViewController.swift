//
//  AuthTokenViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 8/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class AuthTokenViewController: BaseTableViewController {
    
    enum Section: Int {
        case user
        case authToken
        case spear
        case count
    }
    
    enum UserRow: Int {
        case userId
        case count
    }
    
    enum AuthTokenRow: Int {
        case input
        case count
    }
    
    enum SpearRow: Int {
        case environment
        case pin
        case generateToken
        case count
    }
    
    // MARK: Properties
    
    fileprivate let textInputSizingCell = TextInputCell()
    fileprivate let buttonSizingCell = ButtonCell()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        title = "Auth"
    }
    
    // MARK: View
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
}

// MARK:- Cell Styling

extension AuthTokenViewController {
    
    func getCellForRowAt(indexPath: IndexPath, forSizing: Bool = false) -> UITableViewCell {
        switch indexPath.section {
        case Section.user.rawValue: return getUserSectionCell(indexPath: indexPath, forSizing: forSizing)
        case Section.authToken.rawValue: return getAuthTokenSectionCell(indexPath: indexPath, forSizing: forSizing)
        case Section.spear.rawValue: return getSpearIntegrationSectionCell(indexPath: indexPath, forSizing: forSizing)
        default: return TableViewCell()
        }
    }
    
    private func getUserSectionCell(indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch indexPath.row {
        case UserRow.userId.rawValue:
            return titleDetailValueCell(title: "Customer ID",
                                        value: AppSettings.shared.customerIdentifier ?? "Anonymous",
                                        for: indexPath,
                                        sizingOnly: forSizing)

        default: return TableViewCell()
        }
    }
    
    private func getAuthTokenSectionCell(indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch indexPath.row {
        case AuthTokenRow.input.rawValue:
            return textInputCell(text: AppSettings.shared.authToken,
                                 placeholder: "Auth Token",
                                 onTextChange: { (updatedToken) in
                                    
                                 },
                                 for: indexPath,
                                 sizingOnly: forSizing)
            
        default: return TableViewCell()
        }
    }
    
    private func getSpearIntegrationSectionCell(indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch indexPath.row {
        case SpearRow.environment.rawValue:
            return titleDetailValueCell(title: "Environment",
                                        value: "<CURRENT_ENVIRONMENT>",
                                        for: indexPath,
                                        sizingOnly: forSizing)
            
        case SpearRow.pin.rawValue:
            return titleDetailValueCell(title: "PIN",
                                        value: "<CURRENT_PIN",
                                        for: indexPath,
                                        sizingOnly: forSizing)
            
        case SpearRow.generateToken.rawValue:
            return buttonCell(title: "Generate Token", for: indexPath, sizingOnly: forSizing)
            
        default: return TableViewCell()
        }
    }
}

// MARK:- UITableViewDataSource

extension AuthTokenViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.user.rawValue: return UserRow.count.rawValue
        case Section.authToken.rawValue: return AuthTokenRow.count.rawValue
        case Section.spear.rawValue: return SpearRow.count.rawValue
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCellForRowAt(indexPath: indexPath, forSizing: false)
    }
}

// MARK:- UITableViewDelegate

extension AuthTokenViewController {
    
    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.user.rawValue: return "User"
        case Section.authToken.rawValue: return "Authentication"
        case Section.spear.rawValue: return "Spear Integration"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sizer = CGSize(width: tableView.bounds.width, height: 0)
        let cell = getCellForRowAt(indexPath: indexPath, forSizing: true)
        return ceil(cell.sizeThatFits(sizer).height)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case Section.user.rawValue:
            switch indexPath.row {
            case UserRow.userId.rawValue:
                let customerIdVC = CustomerIdViewController()
                customerIdVC.onSelection = { [weak self] (customerIdentifier) in
                    self?.tableView.reloadData()
                    
                    if let strongSelf = self {
                        strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
                    }
                }
                navigationController?.pushViewController(customerIdVC, animated: true)
                break

            default: break
            }
            break
            
        case Section.authToken.rawValue:
            // Do something with auth token here
            break
            
        case Section.spear.rawValue:
            switch indexPath.row {
            case SpearRow.environment.rawValue:
                
                break
                
            case SpearRow.pin.rawValue:
                
                break
                
            case SpearRow.generateToken.rawValue:
                
                break
                
            default: break
            }
            break
            
        default: break
        }
    }
}
