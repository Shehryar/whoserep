//
//  ComponentUIPreviewerViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ComponentUIPreviewerViewController: RefreshableTableViewController {
    
    enum Row: Int {
        case useCases
        case json
        case count
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        title = "UI Previewer"
    }
}

// MARK:- UITableViewDataSource

extension ComponentUIPreviewerViewController {

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.count.rawValue
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "NameReuseId"
        let cell = (tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId))
        
        cell.backgroundColor = ASAPP.styles.colors.backgroundPrimary
        
        let text: String
        switch indexPath.row {
        case Row.useCases.rawValue:
            text = "Use Cases"
            break
            
        default:
            text = "JSON Files"
            break
        }
        
        cell.textLabel?.setAttributedText(text, textStyle: ASAPP.styles.textStyles.body)
        
        return cell
    }
}

// MARK:- UITableViewDelegate

extension ComponentUIPreviewerViewController {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = UseCasePreviewViewController()
        switch indexPath.row {
        case Row.useCases.rawValue:
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
}
