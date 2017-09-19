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
    
    fileprivate var spearEnvironment = AppSettings.shared.spearEnvironment {
        didSet {
            AppSettings.saveObject(spearEnvironment.rawValue, forKey: AppSettings.Key.spearEnvironment)
            
            tableView.reloadRows(at: [IndexPath(row: SpearRow.environment.rawValue,
                                                section: Section.spear.rawValue)],
                                 with: .none)
        }
    }
    
    fileprivate var spearPin: String? = AppSettings.shared.spearPin ?? "1357" {
        didSet {
            if let spearPin = spearPin {
                AppSettings.saveObject(spearPin, forKey: AppSettings.Key.spearPin)
            } else {
                AppSettings.deleteObject(forKey: AppSettings.Key.spearPin)
            }
        }
    }
    
    fileprivate var requestingSpearAuthToken: Bool = false {
        didSet {
            let indexPath = IndexPath(row: SpearRow.generateToken.rawValue, section: Section.spear.rawValue)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        title = "Authentication"
    }
    
    // MARK: View
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
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
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch indexPath.section {
        case Section.user.rawValue:
            switch indexPath.row {
            case UserRow.userId.rawValue:
                return titleDetailValueCell(
                    title: "Customer ID",
                    value: AppSettings.shared.customerIdentifier ?? "Anonymous",
                    for: indexPath,
                    sizingOnly: forSizing)
                
            default: break
            }
            
        case Section.authToken.rawValue:
            switch indexPath.row {
            case AuthTokenRow.input.rawValue:
                return textInputCell(
                    text: AppSettings.shared.authToken,
                    placeholder: "Auth Token",
                    onTextChange: { (updatedToken) in
                        AppSettings.saveObject(updatedToken, forKey: AppSettings.Key.authToken)
                    },
                    for: indexPath,
                    sizingOnly: forSizing)
                
            default: break
            }
            
        case Section.spear.rawValue:
            switch indexPath.row {
            case SpearRow.environment.rawValue:
                return titleDetailValueCell(
                    title: "Environment",
                    value: spearEnvironment.rawValue,
                    for: indexPath,
                    sizingOnly: forSizing)
                
            case SpearRow.pin.rawValue:
                return textInputCell(
                    text: spearPin,
                    placeholder: "Enter PIN",
                    labelText: "PIN",
                    onTextChange: { [weak self] (updatedPin) in
                        self?.spearPin = updatedPin
                    },
                    for: indexPath,
                    sizingOnly: forSizing)
                
            case SpearRow.generateToken.rawValue:
                return buttonCell(
                    title: "Generate Token",
                    loading: requestingSpearAuthToken,
                    for: indexPath,
                    sizingOnly: forSizing)
                
            default: break
            }
            
        default: break
        }
        
        return TableViewCell()
    }
}

// MARK:- UITableViewDelegate

extension AuthTokenViewController {
    
    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.user.rawValue: return "Current User"
        case Section.authToken.rawValue: return "Auth Token"
        case Section.spear.rawValue: return "Spear Integration"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case Section.user.rawValue:
            switch indexPath.row {
            case UserRow.userId.rawValue:
                showCustomerIdViewController()
                break

            default: break
            }
            
        case Section.authToken.rawValue:
            focusOnCell(atIndexPath: indexPath)
            
        case Section.spear.rawValue:
            switch indexPath.row {
            case SpearRow.environment.rawValue:
                showSpearEnvironmentOptions()
                
            case SpearRow.pin.rawValue:
                focusOnCell(atIndexPath: indexPath)
                
            case SpearRow.generateToken.rawValue:
                generateSpearToken()
                
            default: break
            }
            
        default: break
        }
    }
}

// MARK:- Actions

extension AuthTokenViewController {
    
    func focusOnCell(atIndexPath indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
        tableView.scrollToRow(at: indexPath, at: .none, animated: true)
    }
    
    func showCustomerIdViewController() {
        let customerIdVC = CustomerIdViewController()
        customerIdVC.onSelection = { [weak self] (customerIdentifier) in
            self?.tableView.reloadData()
            
            if let strongSelf = self {
                strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
            }
        }
        navigationController?.pushViewController(customerIdVC, animated: true)
    }
    
    func showSpearEnvironmentOptions() {
        let alert = UIAlertController(title: "Select Environment", message: nil, preferredStyle: .actionSheet)
        
        for environment in SpearEnvironment.allValues {
            alert.addAction(UIAlertAction(title: environment.rawValue, style: .default, handler: { [weak self] _ in
                self?.spearEnvironment = environment
            }))
        }
       
        present(alert, animated: true, completion: nil)
    }
    
    func generateSpearToken() {
        guard !requestingSpearAuthToken else {
            return
        }
        
        guard let userId = AppSettings.shared.customerIdentifier, let pin = spearPin else {
            showAlert(title: "Not so fast", message: "Customer ID and PIN are required.")
            return
        }
        
        requestingSpearAuthToken = true
        
        _ = SpearAPI.requestAuthToken(userId: userId, pin: pin, environment: spearEnvironment) { [weak self] (authToken, error) in
            self?.requestingSpearAuthToken = false
            if let authToken = authToken {
                AppSettings.saveObject(authToken, forKey: AppSettings.Key.authToken)
                let indexPath = IndexPath(row: 0, section: Section.authToken.rawValue)
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            } else {
                self?.showAlert(title: "Oops!", message: error ?? "Unable to fetch token.")
            }
        }
    }
}
