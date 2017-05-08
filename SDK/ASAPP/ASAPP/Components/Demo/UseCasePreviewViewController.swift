//
//  UseCasePreviewViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class UseCasePreviewViewController: RefreshableTableViewController {

    // MARK: Properties
    
    var names: [String] = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var filesType: DemoComponentFileType = .useCase {
        didSet {
            refresh()
        }
    }

    // MARK: Content
    
    override func refresh() {
        becomeFirstResponder()
        
        if filesType == .useCase {
            UseCasePreviewAPI.getUseCases { [weak self] (useCases, error) in
                if let useCases = useCases {
                    self?.names = useCases
                }
            }
        } else {
            UseCasePreviewAPI.getJSONFilesNames(completion: { [weak self] (fileNames, error) in
                if let fileNames = fileNames {
                    self?.names = fileNames
                }
            })
        }
    }
}

// MARK:- UITableViewDataSource

extension UseCasePreviewViewController {

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "NameReuseId"
        let cell = (tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId))
        
        cell.backgroundColor = ASAPP.styles.colors.backgroundPrimary
        
        let useCaseId = names[indexPath.row]
        cell.textLabel?.setAttributedText(DemoComponentType.prettifyFileName(useCaseId),
                                          textStyle: ASAPP.styles.textStyles.body)
        cell.detailTextLabel?.setAttributedText(DemoComponentType.fromFileName(useCaseId).rawValue,
                                                textStyle: ASAPP.styles.textStyles.detail1)
    
        return cell
    }
}

// MARK:- UITableViewDelegate

extension UseCasePreviewViewController {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let fileName = names[indexPath.row]
        
        let type = DemoComponentType.fromFileName(fileName)
        switch type {
        case .view, .card:
            let previewVC = ComponentPreviewViewController()
            previewVC.fileInfo = DemoComponentFileInfo(fileName: fileName,
                                                       fileType: filesType)
            navigationController?.pushViewController(previewVC, animated: true)
            break
            
        case .message:
            let viewController = ComponentMessagePreviewViewController()
            viewController.fileInfo = DemoComponentFileInfo(fileName: fileName,
                                                            fileType: filesType)
            navigationController?.pushViewController(viewController, animated: true)
            break
        }
    }
}
