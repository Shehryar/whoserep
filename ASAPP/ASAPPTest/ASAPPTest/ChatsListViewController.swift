//
//  ChatsListViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

struct ASAPPConversation {
    var company: String = ""
    var userToken: String?
    var isCustomer: Bool = true
    
    var description: String {
        return "\(company)|\(userToken ?? "")|\(isCustomer ? "customer" : "rep")"
    }
}

class ChatsListViewController: UIViewController {

    // MARK:- Properties
    
    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    let asapp = ASAPPv2()
    
    let conversations = [
        ASAPPConversation(company: "vs-dev", userToken: "vs-cct-c6", isCustomer: true),
        ASAPPConversation(company: "vs-dev", userToken: "vs-cct-c7", isCustomer: true) // testing
    ]
    
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
        return conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = "cellReuseId"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) ?? UITableViewCell(style: .Default, reuseIdentifier: reuseId)
        
        cell.textLabel?.font = UIFont.systemFontOfSize(16)
        cell.accessoryType = .DisclosureIndicator
        
        let conversation = conversations[indexPath.row]
        cell.textLabel?.text = conversation.description
        
        return cell
    }
}

extension ChatsListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let conversation = conversations[indexPath.row]
        
        let chatViewController = asapp.createChatViewController(withCompany: conversation.company, userToken: conversation.userToken, isCustomer: conversation.isCustomer)
        chatViewController.title = conversation.description
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}
