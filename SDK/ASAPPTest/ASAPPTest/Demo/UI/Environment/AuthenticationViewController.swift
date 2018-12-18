//
//  AuthenticationViewController.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 6/12/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class AuthenticationViewController: BaseTableViewController {
    enum Section: Int, CountableEnum {
        case customerId
        case authToken
        case useAnonymous
        case clearSavedSession
        case chooseAccount
        case addAccount
    }
    
    var onSuccess: (() -> Void)?
    var onTapClearSavedSession: (() -> Void)?
    var showLogInButton = false
    fileprivate var selectedAccount: Account?
    fileprivate var loadingAccount: Account?
    fileprivate var accounts: [Account] = []
    fileprivate var clearedAuthTokenText: String?
    
    override func commonInit() {
        super.commonInit()
        
        title = "Authentication"
        onSuccess = dismiss
        
        let currentToken = AppSettings.shared.authToken
        if let currentCustomerId = AppSettings.shared.customerIdentifier,
           currentToken == AppSettings.fakeToken {
            selectedAccount = Account(username: currentCustomerId, password: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reload()
        
        if showLogInButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log in", style: .done, target: self, action: #selector(onTapLogIn))
        }
    }
    
    @objc fileprivate func onTapLogIn() {
        onSuccess?()
    }
    
    fileprivate func reload() {
        accounts = AppSettings.getAccountArray()
        tableView.reloadData()
    }
    
    fileprivate func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .some(.customerId): return 1
        case .some(.authToken): return 1
        case .some(.useAnonymous): return 1
        case .some(.clearSavedSession): return 1
        case .some(.chooseAccount): return accounts.count
        case .some(.addAccount): return 1
        case .none: return 0
        }
    }
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .some(.customerId):
            return textInputCell(
                text: AppSettings.shared.customerIdentifier ?? " ⃠",
                placeholder: "",
                labelText: "Customer Id",
                onReturnKey: { value in
                    AppSettings.saveObject(value, forKey: .customerIdentifier)
                },
                for: indexPath,
                sizingOnly: forSizing)
        case .some(.authToken):
            return textInputCell(
                text: clearedAuthTokenText ?? AppSettings.shared.authToken,
                placeholder: "",
                labelText: "Auth Token",
                onReturnKey: { [weak self] value in
                    self?.clearedAuthTokenText = nil
                    AppSettings.saveObject(value, forKey: .authToken)
                },
                for: indexPath,
                sizingOnly: forSizing)
        case .some(.useAnonymous):
            return buttonCell(title: "Use anonymous account", for: indexPath, sizingOnly: forSizing)
        case .some(.clearSavedSession):
            return buttonCell(title: "Clear saved session", for: indexPath, sizingOnly: forSizing)
        case .some(.chooseAccount):
            let account = accounts[indexPath.row]
            let title = account.username + (account.password != nil ? "  🔐" : "")
            let loading = account == loadingAccount
            return titleCheckMarkCell(title: title,
                                      isChecked: account == selectedAccount && !loading,
                                      loading: loading,
                                      for: indexPath,
                                      sizingOnly: forSizing)
        case .some(.addAccount):
            return buttonCell(
                title: "Add Account",
                loading: false,
                for: indexPath,
                sizingOnly: forSizing)
        case .none:
            return TableViewCell()
        }
    }

    // MARK: - UITableViewDelegate
    
    override func titleForSection(_ section: Int) -> String? {
        switch Section(rawValue: section) {
        case .some(.customerId): return "\(AppSettings.shared.appId) • \(AppSettings.shared.apiHostName)"
        case .some(.authToken): return nil
        case .some(.useAnonymous): return nil
        case .some(.clearSavedSession): return nil
        case .some(.chooseAccount): return "Choose Account"
        case .some(.addAccount): return ""
        case .none: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch Section(rawValue: indexPath.section) {
        case .some(.customerId):
            focusOnCell(at: indexPath)
        case .some(.authToken):
            focusOnCell(at: indexPath)
        case .some(.useAnonymous):
            useAnonymous()
        case .some(.clearSavedSession):
            onTapClearSavedSession?()
        case .some(.chooseAccount):
            selectAccount(at: indexPath)
        case .some(.addAccount):
            showAddAccountViewController()
        case .none: break
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == Section.authToken.rawValue {
            return true
        }
        
        guard indexPath.section == Section.chooseAccount.rawValue else {
            return false
        }
        
        let account = accounts[indexPath.row]
        
        if AppSettings.defaultAccounts.contains(account) {
            return false
        }
        
        return account != selectedAccount
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if indexPath.section == Section.authToken.rawValue {
            return "Clear"
        } else {
            return "Delete"
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        if indexPath.section == Section.authToken.rawValue {
            AppSettings.deleteObject(forKey: .authToken)
            clearedAuthTokenText = ""
            reload()
            focusOnCell(at: IndexPath(row: 0, section: Section.authToken.rawValue))
        }
        
        if indexPath.section == Section.chooseAccount.rawValue {
            AppSettings.removeAccountFromArray(accounts[indexPath.row])
            reload()
        }
    }
}

extension AuthenticationViewController {
    fileprivate func useAnonymous() {
        selectedAccount = nil
        AppSettings.deleteObject(forKey: .customerIdentifier)
        AppSettings.deleteObject(forKey: .authToken)
        AppSettings.clearMostRecentAccount(appId: AppSettings.shared.appId, apiHostName: AppSettings.shared.apiHostName)
        reload()
        onSuccess?()
    }
    
    fileprivate func fetchAuthToken(completion: (() -> Void)? = nil) {
        guard let account = selectedAccount else {
            return
        }
        
        AppSettings.setMostRecentAccount(account, appId: AppSettings.shared.appId, apiHostName: AppSettings.shared.apiHostName)
        AppSettings.saveObject(account.username, forKey: .customerIdentifier)
        
        guard let password = account.password else {
            AppSettings.deleteObject(forKey: .authToken)
            completion?()
            return
        }
        
        loadingAccount = account
        AuthenticationAPI.requestAuthToken(apiHostName: AppSettings.shared.apiHostName, appId: AppSettings.shared.appId, userId: account.username, password: password) { [weak self] (customerId, authToken, _) in
            self?.loadingAccount = nil
            
            guard let authToken = authToken else {
                self?.selectedAccount = nil
                self?.showAuthTokenFetchError()
                self?.reload()
                return
            }
            
            AppSettings.saveObject(authToken, forKey: .authToken)
            
            if let customerId = customerId {
                AppSettings.saveObject(customerId, forKey: .customerIdentifier)
            }
            
            completion?()
            self?.reload()
        }
    }
    
    fileprivate func showAuthTokenFetchError() {
        let alert = UIAlertController(title: "Could not fetch auth token",
                                      message: "Please check that the API Host and App Id are correct.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func selectAccount(at indexPath: IndexPath) {
        selectedAccount = accounts[indexPath.row]
        reload()
        fetchAuthToken(completion: onSuccess)
    }
    
    fileprivate func showAddAccountViewController() {
        let addAccount = AddAccountViewController()
        addAccount.onFinish = { [weak self] account in
            guard let strongSelf = self else {
                return
            }
            
            AppSettings.addAccountToArray(account)
            strongSelf.selectedAccount = account
            strongSelf.fetchAuthToken()
            strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
        }
        navigationController?.pushViewController(addAccount, animated: true)
    }
}
