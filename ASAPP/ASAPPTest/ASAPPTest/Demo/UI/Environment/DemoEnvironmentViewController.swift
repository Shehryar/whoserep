//
//  DemoEnvironmentViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol DemoEnvironmentViewControllerDelegate: class {
    func demoEnvironmentViewController(_ viewController: DemoEnvironmentViewController, didUpdateAppSettings appSettings: AppSettings)
}

class DemoEnvironmentViewController: BaseTableViewController {

    enum Section: Int {
        case demoContent
        case liveChat
        case colors
        case count
    }
    
    enum ColorsRow: Int {
        case navigation
        case content
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
            
        case Section.liveChat.rawValue:
            return appSettings.supportsLiveChat ? 1 : 0
            
        case Section.colors.rawValue:
            return appSettings.canChangeColors ? ColorsRow.count.rawValue : 0
            
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
            
        case Section.colors.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: TitleToggleCell.reuseId, for: indexPath) as? TitleToggleCell
            styleToggleCell(cell, for: indexPath)
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
            cell.isOn = appSettings.demoContentEnabled
            cell.onToggleChange = { [weak self] (isOn: Bool) in
                if let blockSelf = self {
                    blockSelf.appSettings.demoContentEnabled = isOn
                    blockSelf.delegate?.demoEnvironmentViewController(blockSelf, didUpdateAppSettings: blockSelf.appSettings)
                }
            }
            break
            
        case Section.liveChat.rawValue:
            cell.title = "Demo Live Chat"
            cell.isOn = appSettings.liveChatEnabled
            cell.onToggleChange = { [weak self] (isOn: Bool) in
                if let blockSelf = self {
                    blockSelf.appSettings.liveChatEnabled = isOn
                    blockSelf.delegate?.demoEnvironmentViewController(blockSelf, didUpdateAppSettings: blockSelf.appSettings)
                }
            }
            break
            
        case Section.colors.rawValue:
            switch indexPath.row {
            case ColorsRow.navigation.rawValue:
                cell.title = "Dark Nav Style"
                cell.isOn = appSettings.isDarkNavStyle
                cell.onToggleChange = { [weak self] (isOn: Bool) in
                    guard let blockSelf = self else { return }
                    
                    if isOn {
                        blockSelf.appSettings.useDarkNavStyle()
                    } else {
                        blockSelf.appSettings.useLightNavStyle()
                        blockSelf.appSettings.useLightContentStyle()
                    }
                    DemoDispatcher.performOnMainThread {
                        blockSelf.appSettings = blockSelf.appSettings
                    }
                    
                    blockSelf.delegate?.demoEnvironmentViewController(blockSelf, didUpdateAppSettings: blockSelf.appSettings)
                }
                break
                
            case ColorsRow.content.rawValue:
                cell.title = "Dark Content Style"
                cell.isOn = appSettings.isDarkContentStyle
                cell.onToggleChange = { [weak self] (isOn: Bool) in
                    guard let blockSelf = self else { return }
                    
                    if isOn {
                        blockSelf.appSettings.useDarkContentStyle()
                        blockSelf.appSettings.useDarkNavStyle()
                    } else {
                        blockSelf.appSettings.useLightContentStyle()
                    }
                    DemoDispatcher.performOnMainThread {
                        blockSelf.appSettings = blockSelf.appSettings
                    }
                    
                    blockSelf.delegate?.demoEnvironmentViewController(blockSelf, didUpdateAppSettings: blockSelf.appSettings)
                }
                break
                
            default: break
            }
            break
            
        default: break
        }
    }
}

// MARK:- UITableViewDelegate

extension DemoEnvironmentViewController {

    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.demoContent.rawValue:
            return "DEMO CONTENT"
            
        case Section.liveChat.rawValue:
            return appSettings.supportsLiveChat ? "LIVE CHAT" : nil

        case Section.colors.rawValue:
            return appSettings.canChangeColors ? "COLORS" : nil
            
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sizer = CGSize(width: tableView.bounds.width, height: 0)
        switch indexPath.section {
        case Section.demoContent.rawValue:
            styleToggleCell(toggleSizingCell, for: indexPath)
            return toggleSizingCell.sizeThatFits(sizer).height
            
        case Section.liveChat.rawValue, Section.colors.rawValue:
            styleToggleCell(toggleSizingCell, for: indexPath)
            return toggleSizingCell.sizeThatFits(sizer).height
            
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
