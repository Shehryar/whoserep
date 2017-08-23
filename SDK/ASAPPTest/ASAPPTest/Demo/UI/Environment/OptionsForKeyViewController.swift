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
        case options
        case createNew
        case count
    }
    
    // MARK: Properties
    
    fileprivate(set) var selectedOptionKey: AppSettings.Key?
    
    fileprivate(set) var optionsListKey: AppSettings.Key?
    
    fileprivate(set) var selectedOption: String?
    
    fileprivate(set) var options: [String]?
    
    var onSelection: ((_ selectedOption: String?) -> Void)?
    
    var rightBarButtonItemTitle: String? {
        didSet {
            updateBarButtonItems()
        }
    }
    
    var onRightBarButtonItemTap: (() -> Void)?
    
    var randomEntryPrefix: String?
    
    override func commonInit() {
        super.commonInit()
        
        tableView.allowsSelectionDuringEditing = false
    }
}

// MARK: UIBarButtonItems

extension OptionsForKeyViewController {
    
    func updateBarButtonItems() {
        if let rightBarButtonItemTitle = rightBarButtonItemTitle {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightBarButtonItemTitle, style: .plain, target: self, action: #selector(OptionsForKeyViewController.didTapRightBarButtonItem))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func didTapRightBarButtonItem() {
        onRightBarButtonItemTap?()
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
        
        DemoLog("Found Selected Option: \(String(describing: selectedOption)), for key: \(selectedOptionKey.rawValue)")
        DemoLog("With Options List: \(String(describing: options) ), for key: \(optionsListKey.rawValue)")
        
        tableView.reloadData()
    }
}

// MARK: UITableView

extension OptionsForKeyViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.options.rawValue: return options?.count ?? 0
        case Section.createNew.rawValue: return 1
        default: return 0
        }
    }
    
    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.options.rawValue: return ""
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
            return buttonCell(title: "Create New", for: indexPath, sizingOnly: forSizing)
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == Section.options.rawValue,
            let option = options?[indexPath.row] {
            return option != selectedOption
        }
        return false
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
            if let options = options, let selectedOptionKey = selectedOptionKey {
                let option = options[indexPath.row]
                selectedOption = option
                AppSettings.saveObject(option, forKey: selectedOptionKey)
                tableView.reloadData()
                
                onSelection?(option)
            }
            break
            
        case Section.createNew.rawValue:
            let viewController = TextInputViewController()
            viewController.title = "Add New Option"
            if let title = title {
                viewController.instructionText = "Add \(title)"
            } else {
                viewController.instructionText = "Add Option"
            }
            viewController.randomEntryPrefix = randomEntryPrefix
            viewController.onFinish = { [weak self] (text) in
                guard !text.isEmpty,
                    let strongSelf = self, let optionsListKey = strongSelf.optionsListKey else {
                    return
                }
                
                
                if strongSelf.isRestrictedText(text) {
                    strongSelf.showAlert(title: "Sorry!",
                                         message: "You are not allowed to do this.")
                    return
                }
                
                
                AppSettings.addStringToArray(text, forKey: optionsListKey)
                strongSelf.reload()
                strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
            }
            navigationController?.pushViewController(viewController, animated: true)
            break
            
        default:
            // No-op
            break
        }
    }
    
    func isRestrictedText(_ text: String) -> Bool {
        return [
            "comcast.asapp.com",
            "sprint.asapp.com"
        ].contains(text.lowercased())
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
