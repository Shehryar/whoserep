//
//  DemoSettingsViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/11/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

protocol DemoSettingsViewControllerDelegate {
    func demoSettingsViewController(_ viewController: DemoSettingsViewController, didUpdateEnvironment environment: ASAPPEnvironment)
}

class DemoSettingsViewController: UIViewController {

    var delegate: DemoSettingsViewControllerDelegate?
    
    var statusBarStyle = UIStatusBarStyle.default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    // MARK: Private Properties
    
    fileprivate let toggleCellReuseId = "ToggleCellReuseId"
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    fileprivate let sizingCell = DemoSettingsTableViewCell()
    
    // MARK:- Initialization
    
    func commonInit() {
        title = "Settings"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.register(DemoSettingsTableViewCell.self, forCellReuseIdentifier: toggleCellReuseId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red:0.942, green:0.939, blue:0.948, alpha:1)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-x"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(DemoSettingsViewController.didTapCancel))
        
        self.view.addSubview(tableView)
    }

    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var tableViewTop: CGFloat = 0.0
        if let navBar = navigationController?.navigationBar {
            tableViewTop = navBar.frame.maxY
        }
        let tableViewHeight = view.bounds.height - tableViewTop
        tableView.frame = CGRect(x: 0.0, y: tableViewTop, width: view.bounds.width, height: tableViewHeight)
        tableView.contentInset = UIEdgeInsets.zero
    }
    
    // MARK: Actions

    func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
}

extension DemoSettingsViewController: UITableViewDataSource {
    
    enum Section: Int {
        case environment = 0
        case userSettings = 1
        case count = 2
    }
    
    enum EnvironmentRow: Int {
        case environment = 0
        case demoContent = 1
        case count = 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case Section.environment.rawValue: return EnvironmentRow.count.rawValue
        case Section.userSettings.rawValue: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.environment.rawValue: return "Environment"
        case Section.userSettings.rawValue: return "User Settings"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: toggleCellReuseId, for: indexPath) as? DemoSettingsTableViewCell else {
            print("\n\n\nWhere is the table view cell, bro?\n\n")
            return UITableViewCell()
        }
        
        styleCell(cell: cell, forIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: Utility
    
    func styleCell(cell: DemoSettingsTableViewCell, forIndexPath indexPath: IndexPath) {
        switch indexPath.section {
        case Section.environment.rawValue:
            switch indexPath.row {
            case EnvironmentRow.environment.rawValue:
                cell.title = "Use Production"
                cell.isOn = DemoSettings.currentEnvironment() == .production
                cell.onToggleChange = { [weak self] (isOn: Bool) in
                    if isOn {
                        DemoSettings.setCurrentEnvironment(environment: .production)
                        
                        DemoSettings.setDemoContentEnabled(false)
                        let reloadIndexPath = IndexPath(row: EnvironmentRow.demoContent.rawValue, section: Section.environment.rawValue)
                        self?.tableView.reloadRows(at: [reloadIndexPath], with: .none)
                    } else {
                        DemoSettings.setCurrentEnvironment(environment: .staging)
                    }
                    
                    if let blockSelf = self {
                        blockSelf.delegate?.demoSettingsViewController(blockSelf, didUpdateEnvironment: DemoSettings.currentEnvironment())
                    }
                }
                break
                
            case EnvironmentRow.demoContent.rawValue:
                cell.title = "Demo Content"
                cell.isOn = DemoSettings.demoContentEnabled()
                cell.onToggleChange = { [weak self] (isOn: Bool) in
                    DemoSettings.setDemoContentEnabled(isOn)
                    if isOn {
                        DemoSettings.setCurrentEnvironment(environment: .staging)
                        let reloadIndexPath = IndexPath(row: EnvironmentRow.environment.rawValue, section: Section.environment.rawValue)
                        self?.tableView.reloadRows(at: [reloadIndexPath], with: .none)
                    }
                    
                    if let blockSelf = self {
                        blockSelf.delegate?.demoSettingsViewController(blockSelf, didUpdateEnvironment: DemoSettings.currentEnvironment())
                    }
                }
                break
                
            default:
                // no-op
                break
            }
            break
            
            
        case Section.userSettings.rawValue:
            cell.title = "Ineligible for Upgrades"
            cell.isOn = DemoSettings.ineligibleForPhoneUpgrade()
            cell.onToggleChange = { (isOn: Bool) in
                DemoSettings.setIneligibleForPhoneUpgrade(eligible: isOn)
            }
            break
            
            
        default:
            // No-op
            break
        }
    }
}

extension DemoSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        styleCell(cell: sizingCell, forIndexPath: indexPath)
        let sizedHeight = sizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height
        
    
        return sizedHeight
    }
}
