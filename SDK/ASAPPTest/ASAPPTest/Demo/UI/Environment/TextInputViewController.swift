//
//  TextInputViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 2/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TextInputViewController: BaseTableViewController {

    enum Section: Int {
        case textInput
        case saveButton
        case count
    }
    
    // MARK: Properties
    
    var onFinish: ((_ text: String) -> Void)?
    
    var instructionText: String = ""
    
    var placeholderText: String = "Enter text..."
    
    fileprivate(set) var text: String = ""
    
    fileprivate let buttonSizingCell = ButtonCell()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
    
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseId)
    }
    
    // MARK: - View
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = tableView.cellForRow(at: IndexPath(item: 0, section: Section.textInput.rawValue))?.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    func finish() {
        guard !text.isEmpty else {
            return
        }
        
        onFinish?(text)
    }

    // MARK: - UITableViewDataSource
    
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
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch indexPath.section {
        case Section.textInput.rawValue:
            return textInputCell(text: text,
                                 placeholder: placeholderText,
                                 onTextChange: { [weak self] (updatedText) in
                                    self?.text = updatedText
                                 },
                                 for: indexPath,
                                 sizingOnly: forSizing)
            
        case Section.saveButton.rawValue:
            return buttonCell(title: "Save",
                              for: indexPath,
                              sizingOnly: forSizing)
            
        default: return TableViewCell()
        }
    }

    // MARK: - UITableViewDelegate
    
    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.textInput.rawValue: return instructionText
        case Section.saveButton.rawValue: return ""
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case Section.textInput.rawValue:
            tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
            
        case Section.saveButton.rawValue:
            finish()
            
        default: break
        }
    }
}
