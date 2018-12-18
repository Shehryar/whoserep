//
//  OptionsForKeyViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 6/21/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class OptionsForKeyViewController: BaseTableViewController {

    enum Section: Int {
        case createNew
        case options
        case count
    }
    
    // MARK: Properties
    
    fileprivate(set) var selectedOptionKey: AppSettings.Key?
    
    fileprivate(set) var optionsListKey: AppSettings.Key?
    
    fileprivate(set) var selectedOption: String?
    
    fileprivate(set) var options: [String]?
    
    var onSelection: ((_ selectedOption: String?) -> Void)?
    
    var createCustomOptionTitle: String = "Create New"
    
    var createRandomOptionTitle: String?
    
    var randomEntryPrefix: String?
    
    var deleteSelectedOptionTitle: String?
    
    override func commonInit() {
        super.commonInit()
        
        tableView.allowsSelectionDuringEditing = false
    }
    
    // MARK: UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.options.rawValue: return options?.count ?? 0
        case Section.createNew.rawValue: return numberOfCreateNewRows()
        default: return 0
        }
    }
    
    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.options.rawValue: return "Existing Options"
        case Section.createNew.rawValue: return ""
        default: return nil
        }
    }
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch indexPath.section {
        case Section.options.rawValue:
            if let options = options {
                let optionName = options[indexPath.row]
                
                return titleCheckMarkCell(title: optionName,
                                          isChecked: optionName == selectedOption,
                                          for: indexPath,
                                          sizingOnly: forSizing)
            }
            return UITableViewCell()
            
        case Section.createNew.rawValue:
            return buttonCell(title: titleForCreateNewRow(indexPath.row),
                              for: indexPath,
                              sizingOnly: forSizing)
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == Section.options.rawValue,
            let option = options?[indexPath.row] else {
                return false
        }
        
        if let key = optionsListKey,
            AppSettings.getDefaultStringArray(forKey: key)?.contains(option) ?? false {
            return false
        }
        
        return option != selectedOption
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete && indexPath.section == Section.options.rawValue else {
            return
        }
        
        if let option = options?[indexPath.row], let optionsListKey = optionsListKey {
            AppSettings.deleteStringFromArray(option, forKey: optionsListKey)
            reload()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case Section.options.rawValue:
            if let options = options {
                selectOption(options[indexPath.row])
            }
            
        case Section.createNew.rawValue:
            performActionForCreateNewRow(indexPath.row)
            
        default:
            // No-op
            break
        }
    }
    
    fileprivate func selectOption(_ text: String?) {
        if let selectedOptionKey = selectedOptionKey {
            if let text = text {
                AppSettings.saveObject(text, forKey: selectedOptionKey)
            } else {
                AppSettings.deleteObject(forKey: selectedOptionKey)
            }
        }
        selectedOption = text
        reload()
        
        onSelection?(text)
    }
    
    func isRestrictedText(_ text: String) -> Bool {
        return [
            "sprint.asapp.com"
            ].contains(text.lowercased())
    }
}

// MARK: Data

extension OptionsForKeyViewController {
    
    func update(selectedOptionKey: AppSettings.Key, optionsListKey: AppSettings.Key) {
        self.selectedOptionKey = selectedOptionKey
        self.optionsListKey = optionsListKey
        
        reload()
    }
    
    func reload() {
        guard let selectedOptionKey = selectedOptionKey, let optionsListKey = optionsListKey else {
            selectedOption = nil
            options = nil
            tableView.reloadData()
            return
        }
        
        selectedOption = AppSettings.getString(forKey: selectedOptionKey)
        options = AppSettings.getStringArray(forKey: optionsListKey)
        
        tableView.reloadData()
    }
}

// MARK: Creation Row Helpers

extension OptionsForKeyViewController {
    
    func numberOfCreateNewRows() -> Int {
        var numRows = 1
        if createRandomOptionTitle != nil {
            numRows += 1
        }
        if deleteSelectedOptionTitle != nil {
            numRows += 1
        }
        return numRows
    }
    
    func titleForCreateNewRow(_ row: Int) -> String? {
        switch row {
        case 0: return createCustomOptionTitle
        case 1: return createRandomOptionTitle ?? deleteSelectedOptionTitle
        case 2: return deleteSelectedOptionTitle
        default: return nil
        }
    }
    
    func performActionForCreateNewRow(_ row: Int) {
        switch row {
        case 0:
            createNewOption()
            
        case 1:
            if createRandomOptionTitle != nil {
                createRandomOption()
            } else {
                deleteCurrentSelectedOption()
            }
            
        case 2:
            deleteCurrentSelectedOption()
            
        default:
            // No-op
            break
        }
    }
    
    private func createNewOption() {
        let viewController = TextInputViewController()
        viewController.title = "Add New Option"
        
        if let title = title {
            viewController.instructionText = "Add \(title)"
        } else {
            viewController.instructionText = "Add Option"
        }
        
        viewController.onFinish = { [weak self] text in
            guard !text.isEmpty,
                  let strongSelf = self,
                  let optionsListKey = strongSelf.optionsListKey else {
                return
            }
            
            if strongSelf.isRestrictedText(text) {
                strongSelf.showAlert(title: "Sorry!", message: "You are not allowed to do this.")
                return
            }
            
            var text = text
            if strongSelf.selectedOptionKey == AppSettings.Key.appId {
                text = text.lowercased()
            }
            
            AppSettings.addStringToArray(text, forKey: optionsListKey)
            
            strongSelf.selectOption(text)
            
            strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func createRandomOption() {
        guard let optionsListKey = optionsListKey else {
            showAlert(title: "Dev Bug", message: "optionsListKey required!")
            return
        }
        
        let optionText: String
        if let randomEntryPrefix = randomEntryPrefix {
            optionText = "\(randomEntryPrefix)\(Int(Date().timeIntervalSince1970))"
        } else {
            optionText = "\(Int(Date().timeIntervalSince1970))"
        }
        
        AppSettings.addStringToArray(optionText, forKey: optionsListKey)
        selectOption(optionText)
    }
    
    private func deleteCurrentSelectedOption() {
        selectOption(nil)
    }
}
