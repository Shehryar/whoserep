//
//  PushServiceSelectionViewController.swift
//  ASAPPTest
//
//  Created by Shehryar Hussain on 10/30/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

internal enum PushRegistration {
    case apns
    case uuid

    static let pushServiceKey = "Service"
    static let apnsKey = "APNS"
    static let uuidKey = "UUID"
}

class PushServiceSelectionViewController: BaseTableViewController {
    
    // MARK: TableView Data
    
    enum Section: Int, CountableEnum {
        case pushSelection, save
        
        var description: String {
            switch self {
            case .pushSelection: return "Push Services"
            case .save: return ""
                
            }
        }
    }
    
    enum Rows: Int, CountableEnum {
        case apns, uuid
    }
    
    // MARK: Properties
    
    fileprivate(set) var text: String = ""
    fileprivate(set) var selectedIndex: IndexPath?
    private let UUIDIndexPath = IndexPath(row: Rows.uuid.rawValue, section: Section.pushSelection.rawValue)
    var onFinish: ((_ text: String?) -> Void)?
    fileprivate var pushService = AppSettings.shared.pushServiceIdentifier
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        title = "Push Service"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if let index = pushService["Service"] as? Int {
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
                "Service": Rows.uuid.rawValue,
                "key": text
            ]
            
            onFinish?(text)
        } else {
            pushIdentifier = [
                "Service": Rows.apns.rawValue,
                "key": "dummyToken"
            ]
            UIApplication.shared.registerForRemoteNotifications()
            onFinish?(PushRegistration.apnsKey)
        }
        
        AppSettings.saveObject(pushIdentifier, forKey: .pushServiceIdentifier)
    }
    
    func updateSelection(indexPath: IndexPath) {
        deselectRow(newIndex: indexPath)
        switch Rows(rawValue: indexPath.row) {
        case .some(.apns):
            if let cell = tableView.cellForRow(at: indexPath) as? TitleCheckmarkCell {
                cell.isChecked = true
            }
        case .some(.uuid):
            if let cell = tableView.cellForRow(at: indexPath) as? TextInputCheckmarkCell {
                cell.isChecked = true
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
}

// MARK: UITableViewDataSource

extension PushServiceSelectionViewController {
    
    static let pushServicesCount = 2

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
            case Rows.apns.rawValue:
                return titleCheckMarkCell(title: PushRegistration.apnsKey,
                                          isChecked: false,
                                          for: indexPath,
                                          sizingOnly: forSizing)
            case Rows.uuid.rawValue:
                var pushKey = ""
                if pushService["Service"] as? Int == Rows.uuid.rawValue {
                    pushKey = pushService["key"] as? String ?? ""
                }
                return textInputCheckmarkCell(text: text,
                                     isChecked: false,
                                     placeholder: PushRegistration.uuidKey,
                                     labelText: pushKey,
                                     onTextChange: { [weak self] (updatedText) in
                                        self?.text = updatedText
                                     },
                                     onDidBeginEditing: { [weak self] (text) in
                                        self?.updateSelection(indexPath: IndexPath(row: 1, section: Section.pushSelection.rawValue))
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
}

extension PushServiceSelectionViewController {
    
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
