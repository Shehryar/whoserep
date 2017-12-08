//
//  AppearanceViewController.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 12/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class AppearanceViewController: BaseTableViewController {
    enum Section: Int, CountableEnum {
        case createNew
        case options
    }
    
    var onSelection: ((_ selectedConfig: AppearanceConfig) -> Void)?
    
    fileprivate(set) var selectedOption: AppearanceConfig
    fileprivate(set) var options: [AppearanceConfig]
    
    fileprivate lazy var logoSizingCell = ImageCell()
    
    init() {
        selectedOption = AppSettings.shared.appearanceConfig
        options = AppSettings.getAppearanceConfigArray()
        
        super.init(nibName: nil, bundle: nil)
        
        super.commonInit()
        
        title = "Appearance"
        
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.reuseId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AppearanceViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isMovingToParentViewController {
            selectedOption = AppSettings.shared.appearanceConfig
            options = AppSettings.getAppearanceConfigArray()
            tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .some(.createNew):
            return 1
        case .some(.options):
            return options.count
        case .none:
            return 0
        }
    }
    
    override func titleForSection(_ section: Int) -> String? {
        switch Section(rawValue: section) {
        case .some(.createNew):
            return ""
        case .some(.options):
            return "Existing Options"
        case .none:
            return nil
        }
    }
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .some(.createNew):
            return buttonCell(title: "Create New", for: indexPath, sizingOnly: forSizing)
        case .some(.options):
            return logoCell(image: options[indexPath.row].logoImage, for: indexPath, sizingOnly: forSizing)
        case .none:
            return UITableViewCell()
        }
    }
    
    func logoCell(image: UIImage, for indexPath: IndexPath, sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly ? logoSizingCell : tableView.dequeueReusableCell(withIdentifier: ImageCell.reuseId, for: indexPath) as? ImageCell
        
        let config = options[indexPath.row]
        cell?.customImage = config.logoImage
        cell?.backgroundColor = config.getUIColor(.demoNavBar)
        cell?.separatorInset = .zero
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Section(rawValue: indexPath.section) {
        case .some(.createNew):
            let viewController = EditAppearanceViewController()
            navigationController?.pushViewController(viewController, animated: true)
        case .some(.options):
            let selectedConfig = options[indexPath.row]
            AppSettings.saveAppearanceConfig(selectedConfig)
            onSelection?(selectedConfig)
        case .none:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let config = options[indexPath.row]
        return config.brand == .custom
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let config = options[indexPath.row]
        
        options.remove(at: indexPath.row)
        AppSettings.removeAppearanceConfigFromArray(config)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        if config == AppSettings.shared.appearanceConfig {
            let firstPath = IndexPath(row: 0, section: 0)
            let firstConfig = options[firstPath.row]
            tableView.selectRow(at: firstPath, animated: true, scrollPosition: .bottom)
            AppSettings.saveAppearanceConfig(firstConfig)
            AppSettings.shared.branding = Branding(appearanceConfig: firstConfig)
        }
    }
}
