//
//  ChatsListViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

class ChatsListViewController: UIViewController {

    enum Row: Int {
        case Customer = 0
        case Rep = 1
        case Count = 2
    }
    
    // MARK:- Properties
    
    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    let asapp1 = ASAPP(company:"vs-dev", userToken: "vs-cct-c6", isCustomer: true)
    let asapp2 = ASAPPv2()
    
    // MARK:- Init
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "All Chats"
        automaticallyAdjustsScrollViewInsets = true
        view.backgroundColor = UIColor.whiteColor()
        
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    // MARK:- Status Bar
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

extension ChatsListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.Count.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = "cellReuseId"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) ?? UITableViewCell(style: .Default, reuseIdentifier: reuseId)
        
        cell.textLabel?.font = UIFont.systemFontOfSize(16)
        cell.accessoryType = .DisclosureIndicator
        
        switch indexPath.row {
        case Row.Customer.rawValue:
            cell.textLabel?.text = "Chat v2"
            break
            
        case Row.Rep.rawValue:
            cell.textLabel?.text = "Chat v1"
            break
            
        default:
            cell.textLabel?.text = ""
        }
        
        return cell
    }
}

extension ChatsListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case Row.Customer.rawValue:
            // v2
            let chatViewController = asapp2.createChatViewController(withCompany: "vs-dev", userToken: "vs-cct-c6", isCustomer: true)
            chatViewController.title = "Chat v2"
            navigationController?.pushViewController(chatViewController, animated: true)
            break
            
        case Row.Rep.rawValue:
            let chatViewController = asapp1.viewControllerForChat()
            chatViewController.title = "Chat v1"
            navigationController?.pushViewController(chatViewController, animated: true)
            break
            
        default: break
        }
    }
}
