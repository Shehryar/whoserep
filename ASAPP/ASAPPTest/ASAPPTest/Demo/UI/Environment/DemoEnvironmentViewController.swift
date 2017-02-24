//
//  DemoEnvironmentViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

protocol DemoEnvironmentViewControllerDelegate: class {
    func demoEnvironmentViewController(_ viewController: DemoEnvironmentViewController, didUpdateAppSettings appSettings: AppSettings)
}

class DemoEnvironmentViewController: BaseTableViewController {

    enum Section: Int {
        case demoContent
        case defaultCompany
        case apiHostName
        case count
    }
    
    // MARK: Properties
    
    weak var delegate: DemoEnvironmentViewControllerDelegate?
    
    fileprivate let toggleSizingCell = TitleToggleCell()
    fileprivate let checkmarkSizingCell = TitleCheckmarkCell()
    
    // MARK: Init
    
    required init(appSettings: AppSettings) {
        super.init(appSettings: appSettings)
        
        title = "Environment Settings"
        
        tableView.register(TitleToggleCell.self, forCellReuseIdentifier: TitleToggleCell.reuseId)
        tableView.register(TitleCheckmarkCell.self, forCellReuseIdentifier: TitleCheckmarkCell.reuseId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- UITableViewDataSource

extension DemoEnvironmentViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.demoContent.rawValue:
            return 1
            
        case Section.defaultCompany.rawValue:
            return CompanyPreset.all.count
        
        case Section.apiHostName.rawValue:
            return APIHostNamePreset.all.count
            
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.demoContent.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: TitleToggleCell.reuseId, for: indexPath) as? TitleToggleCell
            styleToggleCell(cell, for: indexPath)
            return cell ?? TableViewCell()
            
        case Section.defaultCompany.rawValue,
             Section.apiHostName.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: TitleCheckmarkCell.reuseId, for: indexPath) as? TitleCheckmarkCell
            styleTitleCheckmarkCell(cell, for: indexPath)
            return cell ?? TableViewCell()
            
        default: return TableViewCell()
        }
    }
    
    // MARK: Cell Styling
    
    func styleToggleCell(_ cell: TitleToggleCell?, for indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.appSettings = appSettings
        
        switch indexPath.section {
        case Section.demoContent.rawValue:
            cell.title = "Demo Content Enabled"
            cell.isOn = ASAPP.isDemoContentEnabled()
            cell.onToggleChange = { [weak self] (isOn: Bool) in
                ASAPP.setDemoContentEnabled(isOn)
                if let strongSelf = self {
                    self?.delegate?.demoEnvironmentViewController(strongSelf, didUpdateAppSettings: strongSelf.appSettings)
                }
            }
            break
            
        default: break
        }
    }
    
    func styleTitleCheckmarkCell(_ cell: TitleCheckmarkCell?, for indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.appSettings = appSettings
        cell.title = nil
        cell.isChecked = false
        
        switch indexPath.section {
        case Section.defaultCompany.rawValue:
            let preset = CompanyPreset.all[indexPath.row]
            cell.title = preset.rawValue
            cell.isChecked = appSettings.defaultCompany == preset.rawValue
            break
            
        case Section.apiHostName.rawValue:
            let preset = APIHostNamePreset.all[indexPath.row]
            cell.title = "\(preset.rawValue)"
            cell.isChecked = appSettings.apiHostName == preset.rawValue
            break
            
        default: break
        }
        
    }
}

// MARK:- UITableViewDelegate

extension DemoEnvironmentViewController {

    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.demoContent.rawValue: return "DEMO CONTENT"
        case Section.defaultCompany.rawValue: return "DEFAULT COMPANY"
        case Section.apiHostName.rawValue: return "API HOST NAME"
            
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sizer = CGSize(width: tableView.bounds.width, height: 0)
        switch indexPath.section {
        case Section.demoContent.rawValue:
            styleToggleCell(toggleSizingCell, for: indexPath)
            return toggleSizingCell.sizeThatFits(sizer).height
            
        case Section.defaultCompany.rawValue, Section.apiHostName.rawValue:
            styleTitleCheckmarkCell(checkmarkSizingCell, for: indexPath)
            return checkmarkSizingCell.sizeThatFits(sizer).height

        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case Section.defaultCompany.rawValue:
            let companyPreset = CompanyPreset.all[indexPath.row]
            appSettings.defaultCompany = companyPreset.rawValue
            delegate?.demoEnvironmentViewController(self, didUpdateAppSettings: appSettings)
            tableView.reloadData()
            break
            
        case Section.apiHostName.rawValue:
            let apiHostNamePreset = APIHostNamePreset.all[indexPath.row]
            appSettings.apiHostName = apiHostNamePreset.rawValue
            delegate?.demoEnvironmentViewController(self, didUpdateAppSettings: appSettings)
            tableView.reloadData()
            break
            
        default: break
        }
    }
}
