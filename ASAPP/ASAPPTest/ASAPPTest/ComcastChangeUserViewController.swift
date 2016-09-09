//
//  ComcastChangeUserViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 9/8/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ComcastChangeUserViewController: UIViewController {

    var currentUser: String?
    
    var onUserSelection: ((String?) -> Void)?
    
    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    // MARK: Init
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK: View
    
    override  func viewDidLoad() {
        super.viewDidLoad()

        tableView.frame = view.bounds
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(ComcastChangeUserViewController.cancelSelection))
    }

    func cancelSelection() {
        onUserSelection?(nil)
    }
}

extension ComcastChangeUserViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = "ReuseId"
        let cell = (tableView.dequeueReusableCellWithIdentifier(reuseId) ??
            UITableViewCell(style: .Default, reuseIdentifier: reuseId))
        
        cell.textLabel?.text = "User \(indexPath.row)"
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(16)
        cell.textLabel?.textColor = UIColor.darkTextColor()
        
        return cell
    }
}

extension ComcastChangeUserViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        onUserSelection?("vs-cct-c\(indexPath.row)")
    }
}
