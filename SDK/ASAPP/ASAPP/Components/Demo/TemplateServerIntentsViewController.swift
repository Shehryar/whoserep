//
//  TemplateServerIntentsViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class TemplateServerIntentsViewController: RefreshableTableViewController {

    // MARK: Properties
    
    var intents: [Intent] = [Intent]() {
        didSet {
            tableView.reloadData()
        }
    }
  
    // MARK: Content
    
    override func refresh() {
        becomeFirstResponder()
        
        UseCasePreviewAPI.getTreewalkIntents { [weak self] (intents, errorString) in
            if let intents = intents {
                self?.intents = intents
            } else {
                self?.showAlert(with: errorString ?? "Unable to fetch intents. Is your server running?")
            }
        }
    }
}

// MARK:- UITableViewDataSource

extension TemplateServerIntentsViewController {

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intents.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "NameReuseId"
        let cell = (tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId))
        
        cell.backgroundColor = ASAPP.styles.colors.backgroundPrimary
        
        let intent = intents[indexPath.row]
        cell.accessoryType = intent.fileName != nil ? .disclosureIndicator : .none
        cell.textLabel?.setAttributedText(intent.code, textStyle: ASAPP.styles.textStyles.body)
        cell.detailTextLabel?.setAttributedText(intent.description, textStyle: ASAPP.styles.textStyles.detail1)
    
        return cell
    }
}

// MARK:- UITableViewDelegate

extension TemplateServerIntentsViewController {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let intent = intents[indexPath.row]
        showPreview(for: intent.code)
    }
}
