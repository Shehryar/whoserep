//
//  DemoEnvironmentViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol DemoEnvironmentViewControllerDelegate: class {
    func demoEnvironmentViewControllerDidUpdateEnvironment(_ viewController: DemoEnvironmentViewController)
}

class DemoEnvironmentViewController: BaseTableViewController {

    enum Section: Int {
        case demoContent
        case liveChat
        case environment
        case count
    }
    
    // MARK: Properties
    
    weak var delegate: DemoEnvironmentViewControllerDelegate?
    
    fileprivate var supportedEnvironments: [DemoEnvironment]
    
    fileprivate let toggleSizingCell = TitleToggleCell()
    fileprivate let checkmarkSizingCell = TitleCheckmarkCell()
    
    // MARK: Init
    
    required init(appSettings: AppSettings) {
        self.supportedEnvironments = appSettings.supportedEnvironments()
        super.init(appSettings: appSettings)
        
        title = "Environment Settings"
        
        tableView.register(TitleToggleCell.self, forCellReuseIdentifier: TitleToggleCell.reuseId)
        tableView.register(TitleCheckmarkCell.self, forCellReuseIdentifier: TitleCheckmarkCell.reuseId)
        
        updateSupportedEnvironments()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Data
    
    func updateSupportedEnvironments() {
        appSettings.updateDemoEnvironment()
        supportedEnvironments = appSettings.supportedEnvironments()
        
        tableView.reloadSections([Section.environment.rawValue], with: .automatic)
    }
}

// MARK:- UITableViewDataSource

extension DemoEnvironmentViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.demoContent.rawValue: return 1
        case Section.liveChat.rawValue:
            if appSettings.supportsLiveChatDemo() {
                return 1
            }
            return 0
            
        case Section.environment.rawValue:
            return supportedEnvironments.count
            
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
            
        case Section.liveChat.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: TitleToggleCell.reuseId, for: indexPath) as? TitleToggleCell
            styleToggleCell(cell, for: indexPath)
            return cell ?? TableViewCell()
            
        case Section.environment.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: TitleCheckmarkCell.reuseId, for: indexPath) as? TitleCheckmarkCell
            styleCheckmarkCell(cell, indexPath: indexPath)
            return cell ?? TableViewCell()
            
        default: return TableViewCell()
        }
    }
    
    // MARK: Cell Styling
    
    func styleToggleCell(_ cell: TitleToggleCell?, for indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        switch indexPath.section {
        case Section.demoContent.rawValue:
            cell.appSettings = appSettings
            cell.title = "Demo Content Enabled"
            cell.isOn = DemoSettings.demoContentEnabled()
            cell.onToggleChange = { [weak self] (isOn: Bool) in
                DemoSettings.setDemoContentEnabled(isOn)
                
                if let blockSelf = self {
                    blockSelf.delegate?.demoEnvironmentViewControllerDidUpdateEnvironment(blockSelf)
                }
            }
            break
            
        case Section.liveChat.rawValue:
            cell.appSettings = appSettings
            cell.title = "Demo Live Chat"
            cell.isOn = DemoSettings.demoLiveChat()
            cell.onToggleChange = { [weak self] (isOn: Bool) in
                DemoSettings.setDemoLiveChat(isOn)
                
                if let blockSelf = self {
                    blockSelf.updateSupportedEnvironments()
                    blockSelf.delegate?.demoEnvironmentViewControllerDidUpdateEnvironment(blockSelf)
                }
            }
            break
            
        default: break
        }
    }
    
    func styleCheckmarkCell(_ cell: TitleCheckmarkCell?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.appSettings = appSettings
        
        let environment = supportedEnvironments[indexPath.row]
        cell.title = DemoEnvironmentDescription(environment: environment, withCompany: appSettings.company)
        cell.isChecked = DemoSettings.demoEnvironment() == environment
    }
}

// MARK:- UITableViewDelegate

extension DemoEnvironmentViewController {

    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.demoContent.rawValue:
            return "DEMO CONTENT"
            
        case Section.liveChat.rawValue:
            if appSettings.supportsLiveChatDemo() {
                return "LIVE CHAT"
            } else {
                return nil
            }
            
        case Section.environment.rawValue:
            return "AVAILABLE ENVIRONMENTS"
            
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sizer = CGSize(width: tableView.bounds.width, height: 0)
        switch indexPath.section {
        case Section.demoContent.rawValue:
            styleToggleCell(toggleSizingCell, for: indexPath)
            return toggleSizingCell.sizeThatFits(sizer).height
            
        case Section.liveChat.rawValue:
            styleToggleCell(toggleSizingCell, for: indexPath)
            return toggleSizingCell.sizeThatFits(sizer).height
            
        case Section.environment.rawValue:
            styleCheckmarkCell(checkmarkSizingCell, indexPath: indexPath)
            return checkmarkSizingCell.sizeThatFits(sizer).height
            
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard indexPath.section == Section.environment.rawValue else { return }
        
        let environment = supportedEnvironments[indexPath.row]
        DemoSettings.setDemoEnvironment(environment: environment)
        tableView.reloadData()
        
        delegate?.demoEnvironmentViewControllerDidUpdateEnvironment(self)
    }
}
