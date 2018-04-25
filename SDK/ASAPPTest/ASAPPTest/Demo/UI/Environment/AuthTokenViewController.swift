//
//  AuthTokenViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 8/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class AuthTokenViewController: BaseTableViewController {
    
    enum Section: Int, CountableEnum {
        case user
        case authToken
        case spear
        case tetris
    }
    
    enum UserRow: Int, CountableEnum {
        case userId
    }
    
    enum AuthTokenRow: Int, CountableEnum {
        case input
    }
    
    enum SpearRow: Int, CountableEnum {
        case environment
        case pin
        case generateToken
    }
    
    enum TetrisRow: Int, CountableEnum {
        case environment
        case password
        case generateToken
    }
    
    // MARK: Properties
    
    fileprivate var onTapNext: (() -> Void)?
    
    fileprivate var spearEnvironment = AppSettings.shared.spearEnvironment {
        didSet {
            AppSettings.saveObject(spearEnvironment.rawValue, forKey: .spearEnvironment)
            
            tableView.reloadRows(at: [
                IndexPath(row: SpearRow.environment.rawValue,
                          section: Section.spear.rawValue)
            ], with: .none)
        }
    }
    
    fileprivate var spearPin: String? = AppSettings.shared.spearPin ?? "1357" {
        didSet {
            if let spearPin = spearPin {
                AppSettings.saveObject(spearPin, forKey: .spearPin)
            } else {
                AppSettings.deleteObject(forKey: .spearPin)
            }
        }
    }
    
    fileprivate var requestingSpearAuthToken: Bool = false {
        didSet {
            let indexPath = IndexPath(row: SpearRow.generateToken.rawValue,
                                      section: Section.spear.rawValue)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    fileprivate var tetrisEnvironment = AppSettings.shared.tetrisEnvironment {
        didSet {
            AppSettings.saveObject(tetrisEnvironment.rawValue, forKey: .tetrisEnvironment)
            
            tableView.reloadRows(at: [
                IndexPath(row: TetrisRow.environment.rawValue,
                          section: Section.tetris.rawValue)
            ], with: .none)
        }
    }
    
    fileprivate var tetrisPassword: String? = AppSettings.shared.tetrisPassword {
        didSet {
            if let tetrisPassword = tetrisPassword {
                AppSettings.saveObject(tetrisPassword, forKey: .tetrisPassword)
            } else {
                AppSettings.deleteObject(forKey: .tetrisPassword)
            }
        }
    }
    
    fileprivate var requestingTetrisAuthToken: Bool = false {
        didSet {
            let indexPath = IndexPath(row: TetrisRow.generateToken.rawValue,
                                      section: Section.tetris.rawValue)
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
    
    func addNextButton(title: String, onTapNext: @escaping (() -> Void)) {
        self.onTapNext = onTapNext
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(didTapNext))
    }
    
    @objc func didTapNext() {
        onTapNext?()
    }
}

// MARK: - UITableViewDataSource

extension AuthTokenViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .some(.user): return UserRow.count
        case .some(.authToken): return AuthTokenRow.count
        case .some(.spear): return SpearRow.count
        case .some(.tetris): return TetrisRow.count
        case .none: return 0
        }
    }
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .some(.user):
            switch UserRow(rawValue: indexPath.row) {
            case .some(.userId):
                return titleDetailValueCell(
                    title: "Customer ID",
                    value: AppSettings.shared.customerIdentifier ?? "Anonymous",
                    for: indexPath,
                    sizingOnly: forSizing)
                
            case .none: break
            }
            
        case .some(.authToken):
            switch AuthTokenRow(rawValue: indexPath.row) {
            case .some(.input):
                return textInputCell(
                    text: AppSettings.shared.authToken,
                    placeholder: "Auth Token",
                    onTextChange: { updatedToken in
                        AppSettings.saveObject(updatedToken, forKey: AppSettings.Key.authToken)
                    },
                    for: indexPath,
                    sizingOnly: forSizing)
                
            case .none: break
            }
            
        case .some(.spear):
            switch SpearRow(rawValue: indexPath.row) {
            case .some(.environment):
                return titleDetailValueCell(
                    title: "Environment",
                    value: spearEnvironment.rawValue,
                    for: indexPath,
                    sizingOnly: forSizing)
                
            case .some(.pin):
                return textInputCell(
                    text: spearPin,
                    placeholder: "Enter PIN",
                    labelText: "PIN",
                    onTextChange: { [weak self] updatedPin in
                        self?.spearPin = updatedPin
                    },
                    for: indexPath,
                    sizingOnly: forSizing)
                
            case .some(.generateToken):
                return buttonCell(
                    title: "Generate Token",
                    loading: requestingSpearAuthToken,
                    for: indexPath,
                    sizingOnly: forSizing)
                
            case .none: break
            }
            
        case .some(.tetris):
            switch TetrisRow(rawValue: indexPath.row) {
            case .some(.environment):
                return titleDetailValueCell(
                    title: "Environment",
                    value: tetrisEnvironment.rawValue,
                    for: indexPath,
                    sizingOnly: forSizing)
                
            case .some(.password):
                return textInputCell(
                    text: tetrisPassword,
                    placeholder: "Enter Password",
                    labelText: "Password",
                    isSecureTextEntry: true,
                    onTextChange: { [weak self] updatedPassword in
                        self?.tetrisPassword = updatedPassword
                    }, for: indexPath, sizingOnly: forSizing)
                
            case .some(.generateToken):
                return buttonCell(
                    title: "Generate Token",
                    loading: requestingTetrisAuthToken,
                    for: indexPath,
                    sizingOnly: forSizing)
                
            case .none: break
            }
            
        case .none: break
        }
        
        return TableViewCell()
    }
}

// MARK: - UITableViewDelegate

extension AuthTokenViewController {
    
    override func titleForSection(_ section: Int) -> String? {
        switch Section(rawValue: section) {
        case .some(.user): return "Current User"
        case .some(.authToken): return "Auth Token"
        case .some(.spear): return "Spear Integration"
        case .some(.tetris): return "Tetris Integration"
        case .none: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch Section(rawValue: indexPath.section) {
        case .some(.user):
            switch UserRow(rawValue: indexPath.row) {
            case .some(.userId):
                showCustomerIdViewController()

            case .none: break
            }
            
        case .some(.authToken):
            focusOnCell(atIndexPath: indexPath)
            
        case .some(.spear):
            switch SpearRow(rawValue: indexPath.row) {
            case .some(.environment):
                showSpearEnvironmentOptions()
                
            case .some(.pin):
                focusOnCell(atIndexPath: indexPath)
                
            case .some(.generateToken):
                tableView.endEditing(true)
                generateSpearToken()
                
            case .none: break
            }
            
        case .some(.tetris):
            switch TetrisRow(rawValue: indexPath.row) {
            case .some(.environment):
                showTetrisEnvironmentOptions()
                
            case .some(.password):
                focusOnCell(atIndexPath: indexPath)
                
            case .some(.generateToken):
                tableView.endEditing(true)
                generateTetrisToken()
                
            case .none: break
            }
            
        case .none: break
        }
    }
}

// MARK: - Actions

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
        
        SpearAPI.requestAuthToken(userId: userId, pin: pin, environment: spearEnvironment) { [weak self] authToken, error in
            self?.requestingSpearAuthToken = false
            if let authToken = authToken {
                AppSettings.saveObject(authToken, forKey: .authToken)
                let indexPath = IndexPath(row: 0, section: Section.authToken.rawValue)
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            } else {
                self?.showAlert(title: "Oops!", message: error ?? "Unable to fetch token.")
            }
        }
    }
    
    func showTetrisEnvironmentOptions() {
        let alert = UIAlertController(title: "Select Environment", message: nil, preferredStyle: .actionSheet)
        
        for environment in TetrisEnvironment.allValues {
            alert.addAction(UIAlertAction(title: environment.rawValue, style: .default, handler: { [weak self] _ in
                self?.tetrisEnvironment = environment
            }))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func generateTetrisToken() {
        guard !requestingTetrisAuthToken else {
            return
        }
        
        guard let userId = AppSettings.shared.customerIdentifier, let password = tetrisPassword else {
            showAlert(title: "Not so fast", message: "Customer ID and password are required.")
            return
        }
        
        requestingTetrisAuthToken = true
        
        TetrisAPI.requestAuthToken(userId: userId, password: password, environment: tetrisEnvironment) { [weak self] authToken, error in
            self?.requestingTetrisAuthToken = false
            
            guard let authToken = authToken else {
                self?.showAlert(title: "Oops!", message: error ?? "Unable to fetch token.")
                return
            }
            
            AppSettings.saveObject(authToken, forKey: .authToken)
            let indexPath = IndexPath(row: 0, section: Section.authToken.rawValue)
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}
