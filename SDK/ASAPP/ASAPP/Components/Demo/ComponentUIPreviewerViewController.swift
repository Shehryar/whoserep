//
//  ComponentUIPreviewerViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ComponentUIPreviewerViewController: RefreshableTableViewController {
    
    enum Section: Int {
        case templateServer
        case treewalkServer
        case count
    }
    
    enum TemplateServerRow: Int {
        case useCases
        case json
        case count
    }
    
    enum TreewalkServerRow: Int {
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
        
        title = "UI Previewer"
        
        tableView.register(COMTextInputCell.self, forCellReuseIdentifier: COMTextInputCell.reuseId)
    }
}

// MARK:- UITableViewDataSource

extension ComponentUIPreviewerViewController {

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.templateServer.rawValue:
            return TemplateServerRow.count.rawValue
            
        case Section.treewalkServer.rawValue:
            return TreewalkServerRow.count.rawValue
            
        default:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.templateServer.rawValue:
            return "Template Server"
            
        case Section.treewalkServer.rawValue:
            return "Treewalk Sever"
            
        default:
            return nil
        }
    }

    func templateServerCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell  {
        let cell = (tableView.dequeueReusableCell(withIdentifier: reuseIdLeftTextCell)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdLeftTextCell))
        
        cell.backgroundColor = ASAPP.styles.colors.backgroundPrimary
        
        let text: String
        switch indexPath.row {
        case TemplateServerRow.useCases.rawValue:
            text = "Use Cases"
            break
            
        case TemplateServerRow.json.rawValue:
            text = "JSON Files"
            break
            
        default:
            text = ""
            break
        }
        
        cell.textLabel?.setAttributedText(text, textStyle: ASAPP.styles.textStyles.body)
        
        return cell

    }
    
    func treewalkServerCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell  {
        switch indexPath.row {
        case TreewalkServerRow.input.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: COMTextInputCell.reuseId) as! COMTextInputCell
            cell.placeholderText = "Enter Classification"
            cell.currentText = classification ?? ""
            cell.onTextChange = { [weak self] (text) in
                self?.classification = text
            }
            cell.textField.autocapitalizationType = .none
            cell.textField.autocorrectionType = .no
            cell.backgroundColor = ASAPP.styles.colors.backgroundPrimary
            return cell
            
        case TreewalkServerRow.button.rawValue:
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
        case Section.templateServer.rawValue:
            return templateServerCell(tableView, for: indexPath)
         
        case Section.treewalkServer.rawValue:
            return treewalkServerCell(tableView, for: indexPath)
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK:- UITableViewDelegate

extension ComponentUIPreviewerViewController {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case Section.templateServer.rawValue:
            handleTemplateServerRowTap(indexPath)
            break
            
        case Section.treewalkServer.rawValue:
            handleTreewalkServerRowTap(indexPath)
            break
            
        default:
            // No-op
            break
        }
    }
    
    func handleTemplateServerRowTap(_ indexPath: IndexPath) {
        let viewController = UseCasePreviewViewController()
        switch indexPath.row {
        case TemplateServerRow.useCases.rawValue:
            viewController.title = "Use Cases"
            viewController.filesType = .useCase
            break
            
        default:
            viewController.title = "JSON Files"
            viewController.filesType = .json
            break
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func handleTreewalkServerRowTap(_ indexPath: IndexPath) {
        switch indexPath.row {
        case TreewalkServerRow.input.rawValue:
            tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
            break
            
        case TreewalkServerRow.button.rawValue:
            if let classification = classification, classification.characters.count > 0 {
                getTreewalk(for: classification)
            } else {
                showAlert(with: "Please enter a classification")
            }
            break
            
        default:
            // No-op
            break
        }
    }
    
    func getTreewalk(for classification: String) {
        UseCasePreviewAPI.getTreewalk(with: classification) { [weak self] (message, viewContainer, error) in
            if let error = error {
                self?.showAlert(with: error)
                return
            }
            
            DebugLog.d("Received: message=\(message != nil), view=\(viewContainer != nil)")
            
            if let message = message {
                let viewController = ComponentMessagePreviewViewController()
                viewController.setMessage(message, with: classification)
                self?.navigationController?.pushViewController(viewController, animated: true)
            } else if let viewContainer = viewContainer {
                let previewVC = ComponentPreviewViewController()
                previewVC.setComponentViewContainer(viewContainer, with: classification)
                self?.navigationController?.pushViewController(previewVC, animated: true)
            } else {
                self?.showAlert(with: "Unable to determine contents of response. Please check that your JSON follows proper MitchML.")
            }
        }
    }
    
    func showAlert(title: String? = nil, with message: String?) {
        let alert = UIAlertController(title: title ?? "Oops!",
                                      message: message ?? "You messed up, bro",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
