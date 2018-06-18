//
//  AddAccountViewController.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 6/13/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class AddAccountViewController: BaseTableViewController {
    enum Section: Int, CountableEnum {
        case addAccount
        case save
    }
    
    enum InputRow: Int, CountableEnum {
        case username
        case password
    }
    
    var onFinish: ((Account) -> Void)?
    
    fileprivate var username: String = ""
    fileprivate var password: String = ""
    
    override func commonInit() {
        super.commonInit()
        
        title = "Add Account"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        focusOnCell(at: IndexPath(row: InputRow.username.rawValue, section: Section.addAccount.rawValue))
    }
}

// MARK: - UITableViewDataSource

extension AddAccountViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .some(.addAccount): return InputRow.count
        case .some(.save): return 1
        case .none: return 0
        }
    }
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .some(.addAccount):
            switch InputRow(rawValue: indexPath.row) {
            case .some(.username):
                return textInputCell(
                    text: "",
                    placeholder: "Enter username",
                    labelText: "Username",
                    onTextChange: { [weak self] text in
                        self?.username = text
                    },
                    for: indexPath,
                    sizingOnly: forSizing)
            case .some(.password):
                return textInputCell(
                    text: "",
                    placeholder: "Enter password",
                    labelText: "Password",
                    onTextChange: { [weak self] text in
                        self?.password = text
                    },
                    for: indexPath,
                    sizingOnly: forSizing)
            case .none: break
            }
        case .some(.save):
            return buttonCell(title: "Add", for: indexPath, sizingOnly: forSizing)
        case .none: break
        }
        return TableViewCell()
    }
}

// MARK: - UITableViewDelegate

extension AddAccountViewController {
    override func titleForSection(_ section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch Section(rawValue: indexPath.section) {
        case .some(.addAccount):
            switch InputRow(rawValue: indexPath.row) {
            case .some(.username):
                focusOnCell(at: indexPath)
            case .some(.password):
                focusOnCell(at: indexPath)
            case .none:
                return
            }
        case .some(.save):
            finish()
        case .none: return
        }
    }
}

extension AddAccountViewController {
    fileprivate func finish() {
        let passwordOrNil = password.isEmpty ? nil : password
        let account = Account(username: username, password: passwordOrNil)
        onFinish?(account)
    }
}
