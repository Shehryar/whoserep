//
//  BaseTableViewController.swift
//  Analytics
//
//  Created by Mitchell Morgan on 10/19/16.
//  Copyright © 2016 ASAPP, Inc. All rights reserved.
//

import UIKit

class BaseTableViewController: BaseViewController {
    
    // MARK:- Properties
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK:- Initialization
    
    required init(appSettings: AppSettings) {
        super.init(appSettings: appSettings)
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.backgroundColor = UIColor(red:0.898, green:0.898, blue:0.898, alpha:1)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.lightGray
        view.addSubview(tableView)
    }
    
    // MARK:- Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        print("here")
        var insetTop: CGFloat = 0.0
        if let navBar = navigationController?.navigationBar {
            insetTop = navBar.frame.maxY
        }
        
        tableView.frame = view.bounds
        tableView.contentInset = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
    }
}

// MARK:- UITableViewCell Helpers

extension BaseTableViewController {
    
    func textCell(forIndexPath indexPath: IndexPath, title: String?,
                  detailText: String? = nil,
                  accessoryType: UITableViewCellAccessoryType = .none) -> UITableViewCell {
        let textCellReuseId = "TextCellReuseId"
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellReuseId) ?? UITableViewCell(style: .value1, reuseIdentifier: textCellReuseId)
        
        cell.textLabel?.text = title
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cell.textLabel?.textColor = UIColor.darkGray
        
        cell.detailTextLabel?.text = detailText
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.detailTextLabel?.textColor = UIColor.gray
        
        cell.accessoryType = accessoryType
        
        return cell
    }
}

// MARK:- UITableViewDataSource

extension BaseTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Subclass must override tableView:cellForRowAt:")
    }
}

// MARK:- UITableViewDelegate

extension BaseTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // No-op
    }
}


