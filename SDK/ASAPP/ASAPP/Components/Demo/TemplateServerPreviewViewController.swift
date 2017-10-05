//
//  TemplateServerPreviewViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class TemplateServerPreviewViewController: RefreshableTableViewController {
    
    enum Section: Int {
        case allIntents
        case specificIntent
        case count
    }
    
    enum SpecificIntentRow: Int {
        case input
        case button
        case count
    }
    
    // MARK: Properties
    
    let reuseIdLeftTextCell = "LeftTextCell"
    
    let reuseIdCenterTextCell = "CenterTextCell"
    
    var classification: String?
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        title = "Template Previewer"
        
        tableView.register(COMTextInputCell.self, forCellReuseIdentifier: COMTextInputCell.reuseId)
    }
}

// MARK:- UITableViewDataSource

extension TemplateServerPreviewViewController {

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.allIntents.rawValue: return 1
            
        case Section.specificIntent.rawValue:
            return SpecificIntentRow.count.rawValue
            
        default:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.allIntents.rawValue: return nil
            
        case Section.specificIntent.rawValue:
            return "Specific Intent"
            
        default:
            return nil
        }
    }

    func allIntentsCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: reuseIdLeftTextCell)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdLeftTextCell))
        
        cell.backgroundColor = ASAPP.styles.colors.backgroundPrimary
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.setAttributedText("List of Intents", textStyle: ASAPP.styles.textStyles.body)
        
        return cell

    }
    
    func treewalkServerCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case SpecificIntentRow.input.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: COMTextInputCell.reuseId) as! COMTextInputCell
            cell.placeholderText = "Enter intent or file name"
            cell.currentText = classification ?? ""
            cell.onTextChange = { [weak self] (text) in
                self?.classification = text
            }
            cell.textField.autocapitalizationType = .none
            cell.textField.autocorrectionType = .no
            cell.backgroundColor = ASAPP.styles.colors.backgroundPrimary
            return cell
            
        case SpecificIntentRow.button.rawValue:
            let cell = (tableView.dequeueReusableCell(withIdentifier: reuseIdCenterTextCell)
                ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdCenterTextCell))
            cell.backgroundColor = ASAPP.styles.colors.backgroundPrimary
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.setAttributedText("Check View",
                                              textStyle: ASAPP.styles.textStyles.button,
                                              color: ASAPP.styles.colors.textButtonPrimary.textNormal)
            return cell

        default:
            return UITableViewCell()
         
        }
        
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.allIntents.rawValue:
            return allIntentsCell(tableView, for: indexPath)
         
        case Section.specificIntent.rawValue:
            return treewalkServerCell(tableView, for: indexPath)
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK:- UITableViewDelegate

extension TemplateServerPreviewViewController {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case Section.allIntents.rawValue:
            handleTemplateServerRowTap(indexPath)
            break
            
        case Section.specificIntent.rawValue:
            handleSpecificIntentRowTap(indexPath)
            break
            
        default:
            // No-op
            break
        }
    }
    
    func handleTemplateServerRowTap(_ indexPath: IndexPath) {
        let viewController = TemplateServerIntentsViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func handleSpecificIntentRowTap(_ indexPath: IndexPath) {
        switch indexPath.row {
        case SpecificIntentRow.input.rawValue:
            tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
            break
            
        case SpecificIntentRow.button.rawValue:
            if let classification = classification, classification.characters.count > 0 {
                showPreview(for: classification)
            } else {
                showAlert(with: "Please enter a classification")
            }
            break
            
        default:
            // No-op
            break
        }
    }
}
