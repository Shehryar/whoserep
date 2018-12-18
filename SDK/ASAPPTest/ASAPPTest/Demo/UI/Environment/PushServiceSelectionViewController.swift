//
//  PushServiceSelectionViewController.swift
//  ASAPPTest
//
//  Created by Shehryar Hussain on 10/30/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

internal enum PushRegistration: Int, CountableEnum {
    case apns
    case uuid

    static let serviceKey = "Service"
    static let tokenKey = "token"
    static let apnsKey = "APNS"
    static let uuidKey = "UUID"
}

class PushServiceSelectionViewController: BaseTableViewController {
    
    // MARK: TableView Data
    
    enum Section: Int, CountableEnum {
        case pushSelection
        case save
        
        var description: String {
            switch self {
            case .pushSelection: return ""
            case .save: return ""
            }
        }
    }
    
    // MARK: Properties
    
    var onFinish: ((_ text: String?) -> Void)?
    
    fileprivate(set) var text: String = ""
    fileprivate(set) var selectedIndex: IndexPath?
    fileprivate var pushService = AppSettings.shared.pushServiceIdentifier
    private let UUIDIndexPath = IndexPath(row: PushRegistration.uuid.rawValue, section: Section.pushSelection.rawValue)
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        title = "Push Service"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if let index = pushService[PushRegistration.serviceKey] as? Int {
            updateSelection(indexPath: IndexPath(row: index, section: Section.pushSelection.rawValue))
        }
    }
    
    func finish() {
        var  pushIdentifier: [String: Any]
        if selectedIndex == UUIDIndexPath {
            guard !text.isEmpty else {
                return
            }
            pushIdentifier = [
                PushRegistration.serviceKey: PushRegistration.uuid.rawValue,
                PushRegistration.tokenKey: text
            ]
            
            onFinish?(text)
        } else {
            pushIdentifier = [
                PushRegistration.serviceKey: PushRegistration.apns.rawValue,
                PushRegistration.tokenKey: "dummyToken"
            ]
            UIApplication.shared.registerForRemoteNotifications()
            onFinish?(PushRegistration.apnsKey)
        }
        
        AppSettings.saveObject(pushIdentifier, forKey: .pushServiceIdentifier)
    }
    
    func updateSelection(indexPath: IndexPath) {
        deselectRow(newIndex: indexPath)
        switch PushRegistration(rawValue: indexPath.row) {
        case .some(.apns):
            if let cell = tableView.cellForRow(at: indexPath) as? TitleCheckmarkCell {
                cell.isChecked = true
            }
        case .some(.uuid):
            if let cell = tableView.cellForRow(at: indexPath) as? TextInputCheckmarkCell {
                cell.isChecked = true
                cell.becomeFirstResponder()
            }
        default:
            return
        }
        
        selectedIndex = indexPath
    }
    
    func deselectRow(newIndex: IndexPath) {
        if newIndex == selectedIndex { return }
        guard let index = selectedIndex else { return }
        if let cell = tableView.cellForRow(at: index) as? TextInputCheckmarkCell {
            cell.isChecked = false
            cell.resignFirstResponder()
        }
        
        if let cell = tableView.cellForRow(at: index) as? TitleCheckmarkCell {
            cell.isChecked = false
        }
    }

    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.pushSelection.rawValue:
            return 2
        default:
            return 1
        }
    }
    
    override func titleForSection(_ section: Int) -> String? {
        return Section(rawValue: section)?.description
    }
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch indexPath.section {
        case Section.pushSelection.rawValue:
            switch indexPath.row {
            case PushRegistration.apns.rawValue:
                return titleCheckMarkCell(title: PushRegistration.apnsKey,
                                          isChecked: false,
                                          for: indexPath,
                                          sizingOnly: forSizing)
            case PushRegistration.uuid.rawValue:
                var pushKey = ""
                if pushService[PushRegistration.serviceKey] as? Int == PushRegistration.uuid.rawValue {
                    pushKey = pushService[PushRegistration.tokenKey] as? String ?? ""
                }
                return textInputCheckmarkCell(
                    text: text,
                    isChecked: false,
                    placeholder: PushRegistration.uuidKey,
                    labelText: pushKey,
                    onTextChange: { [weak self] (updatedText) in
                        self?.text = updatedText
                    },
                    onDidBeginEditing: { [weak self] (text) in
                        self?.updateSelection(indexPath: IndexPath(row: PushRegistration.uuid.rawValue, section: Section.pushSelection.rawValue))
                        self?.text = text
                    },
                    for: indexPath,
                    sizingOnly: forSizing)
            default: return textCell(forIndexPath: indexPath, title: "")
            }
        case Section.save.rawValue:
            return buttonCell(title: "Save",
                              for: indexPath,
                              sizingOnly: forSizing)
            
        default: return TableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case Section.pushSelection.rawValue:
            updateSelection(indexPath: indexPath)
            
        case Section.save.rawValue:
            finish()
            
        default: break
        }
    }
}
