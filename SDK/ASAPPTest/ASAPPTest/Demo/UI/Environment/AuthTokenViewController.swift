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
        case spear
        case count
    }
    
    enum UserRow: Int {
        case userId
        case authToken
        case count
    }
    
    enum SpearRow: Int {
        case environment
        case pin
        case count
    }
    
    // MARK: Properties
    
    var onFinish: ((_ user: String, _ authToken: String) -> Void)?
    
    fileprivate let textInputSizingCell = TextInputCell()
    fileprivate let buttonSizingCell = ButtonCell()
    
    // MARK: Init
    
    
    override func commonInit() {
        super.commonInit()
        
        tableView.register(TextInputCell.self, forCellReuseIdentifier: TextInputCell.reuseId)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseId)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Anon",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(AuthTokenViewController.useAnonymousUser))
    }
    
    // MARK:- Actions
    
    func useAnonymousUser() {
        
    }
    
    func useRandomUser() {
        let text = "ASAPPDemoUser-\(Int(Date().timeIntervalSince1970))"
        tableView.reloadData()
    }
    
    func finish() {
        
    }
}

// MARK:- UITableViewDataSource

extension AuthTokenViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.textInput.rawValue,
             Section.saveButton.rawValue:
            return 1
            
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.textInput.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextInputCell.reuseId, for: indexPath) as? TextInputCell
            styleTextInputCell(cell, for: indexPath)
            return cell ?? TableViewCell()
            
        case Section.saveButton.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseId, for: indexPath) as? ButtonCell
            styleButtonCell(cell, for: indexPath)
            return cell ?? TableViewCell()
            
        default: return TableViewCell()
        }
    }
    
    // MARK: Cell Styling
    
    func styleTextInputCell(_ cell: TextInputCell?, for indexPath: IndexPath) {
        guard let cell = cell else {
            return
        }
        
        cell.appSettings = AppSettings.shared
        cell.currentText = text
        cell.placeholderText = placeholderText
        cell.textField.autocorrectionType = .no
        cell.textField.autocapitalizationType = .none
        cell.textField.returnKeyType = .done
        cell.dismissKeyboardOnReturn = true
        cell.onTextChange = { [weak self] (text) in
            self?.text = text
        }
    }
    
    func styleButtonCell(_ cell: ButtonCell?, for indexPath: IndexPath) {
        guard let cell = cell else {
            return
        }
        cell.appSettings = AppSettings.shared
        cell.title = "Save"
    }
}

// MARK:- UITableViewDelegate

extension AuthTokenViewController {
    
    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.textInput.rawValue: return instructionText
        case Section.saveButton.rawValue: return ""
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sizer = CGSize(width: tableView.bounds.width, height: 0)
        switch indexPath.section {
        case Section.textInput.rawValue:
            styleTextInputCell(textInputSizingCell, for: indexPath)
            return textInputSizingCell.sizeThatFits(sizer).height
            
        case Section.saveButton.rawValue:
            styleButtonCell(buttonSizingCell, for: indexPath)
            return buttonSizingCell.sizeThatFits(sizer).height
            
            
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case Section.textInput.rawValue:
            tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
            break
            
        case Section.saveButton.rawValue:
            finish()
            break
            
        default: break
        }
    }
}
