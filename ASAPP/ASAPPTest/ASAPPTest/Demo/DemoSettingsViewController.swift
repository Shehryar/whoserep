//
//  DemoSettingsViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/11/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

protocol DemoSettingsViewControllerDelegate: class {
    func demoSettingsViewControllerDidUpdateSettings(_ viewController: DemoSettingsViewController)
}

class DemoSettingsViewController: UIViewController {

    weak var delegate: DemoSettingsViewControllerDelegate?
    
    var statusBarStyle = UIStatusBarStyle.default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    // MARK: Private Properties
    
    fileprivate var demoContentEnabled: Bool {
        return DemoSettings.demoContentEnabled()
    }
    
    fileprivate let toggleCellReuseId = "ToggleCellReuseId"
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    fileprivate let sizingCell = DemoSettingsTableViewCell()
    
    // MARK:- Initialization
    
    func commonInit() {
        title = "Settings"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(red:0.942, green:0.939, blue:0.948, alpha:1)
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
        case demoContent = 1
        case comcastDemo = 2
        case count = 3
    }
    
    enum DemoContentRow: Int {
        case demoContentEnabled = 0
        case phoneUpgradeEligibility = 1
        case count = 2
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if COMCAST_LIVE_CHAT_DEMO {
            if section == Section.comcastDemo.rawValue {
                return 1
            }
            return 0
        }
        
        switch section {
        case Section.environment.rawValue: return 1
        case Section.demoContent.rawValue: return demoContentEnabled ? DemoContentRow.count.rawValue : 1
        case Section.comcastDemo.rawValue: return 0
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if COMCAST_LIVE_CHAT_DEMO {
            if section == Section.comcastDemo.rawValue {
                return "Comcast Demo"
            }
            return nil
        }
        
        switch section {
        case Section.environment.rawValue: return "Environment"
        case Section.demoContent.rawValue: return "Demo Content"
        case Section.comcastDemo.rawValue: return nil
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: toggleCellReuseId, for: indexPath) as? DemoSettingsTableViewCell else {
            return UITableViewCell()
        }
        
        styleCell(cell: cell, forIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: Utility
    
    func styleCell(cell: DemoSettingsTableViewCell, forIndexPath indexPath: IndexPath) {
        cell.clipsToBounds = true
        
        switch indexPath.section {
        case Section.environment.rawValue:
            cell.title = "Use Production"
            cell.isOn = DemoSettings.currentEnvironment() == .production
            cell.onToggleChange = { (isOn: Bool) in
                if isOn {
                    DemoSettings.setCurrentEnvironment(environment: .production)
                    
                    DemoSettings.setDemoContentEnabled(false)
                    self.reloadDemoContentSection(reloadFirstRow: true)
                } else {
                    DemoSettings.setCurrentEnvironment(environment: .staging)
                }
                
                self.delegate?.demoSettingsViewControllerDidUpdateSettings(self)
            }
            break
            
            
        case Section.demoContent.rawValue:
            switch indexPath.row {
            case DemoContentRow.demoContentEnabled.rawValue:
                cell.title = "Demo Content Enabled"
                cell.isOn = DemoSettings.demoContentEnabled()
                cell.onToggleChange = { (isOn: Bool) in
                    DemoSettings.setDemoContentEnabled(isOn)
                    if isOn {
                        DemoSettings.setCurrentEnvironment(environment: .staging)
                    }
                    
                    self.reloadDemoContentSection(reloadFirstRow: false, additionalTableViewUpdates: {
                        self.reloadEnvironmentCell()
                    })
                    
                    self.delegate?.demoSettingsViewControllerDidUpdateSettings(self)
                }
                break
                
            case DemoContentRow.phoneUpgradeEligibility.rawValue:
                cell.title = "Ineligible for Phone Upgrades"
                cell.isOn = DemoSettings.ineligibleForPhoneUpgrade()
                cell.onToggleChange = { (isOn: Bool) in
                    DemoSettings.setIneligibleForPhoneUpgrade(eligible: isOn)
                    self.delegate?.demoSettingsViewControllerDidUpdateSettings(self)
                }
                break
                
            default:
                // No-op
                break
            }
            break
            
        case Section.comcastDemo.rawValue:
            cell.title = "User: +13126089137"
            cell.isOn = DemoSettings.useComcastPhoneUser()
            cell.onToggleChange = { (isOn: Bool) in
                DemoSettings.setUseComcastPhoneUser(isOn)
                self.delegate?.demoSettingsViewControllerDidUpdateSettings(self)
            }
            break
            
        default:
            // No-op
            break
        }
    }
    
    func reloadEnvironmentCell() {
        tableView.beginUpdates()
        let indexPath = IndexPath(item: 0, section: Section.environment.rawValue)
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.endUpdates()
    }
    
    func reloadDemoContentSection(reloadFirstRow: Bool, additionalTableViewUpdates: (() -> Void)? = nil) {
        
        tableView.beginUpdates()
        
        let section = Section.demoContent.rawValue
        
        // Reload the first cell
        if reloadFirstRow {
            let indexPath = IndexPath(item: DemoContentRow.demoContentEnabled.rawValue, section: section)
            if let toggleCell = tableView.cellForRow(at: indexPath) as? DemoSettingsTableViewCell {
                toggleCell.isOn = demoContentEnabled
            }
        }
        
        // Add/remove other cells as necessary
        
        let numberExistingRows = tableView.numberOfRows(inSection: section)
        let rowsAfterUpdate = tableView(tableView, numberOfRowsInSection: section)
        
        var indexPaths = [IndexPath]()
        for row in min(numberExistingRows, rowsAfterUpdate)..<max(numberExistingRows, rowsAfterUpdate) {
            indexPaths.append(IndexPath(row: row, section: section))
        }
        
        // Remove rows
        if numberExistingRows > rowsAfterUpdate {
            tableView.deleteRows(at: indexPaths, with: .automatic)
        }
        // Insert rows
        else if numberExistingRows < rowsAfterUpdate {
            tableView.insertRows(at: indexPaths, with: .top)
        }
        
        additionalTableViewUpdates?()
        
        tableView.endUpdates()
    }
}

// MARK:- UITableViewDelegate

extension DemoSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        styleCell(cell: sizingCell, forIndexPath: indexPath)
        let sizedHeight = sizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height
        
    
        return sizedHeight
    }
}
