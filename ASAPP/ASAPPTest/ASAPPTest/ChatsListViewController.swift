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

    enum ChatSection: Int {
        case CustomerChats = 0
        case RepChats = 1
        case TwoWayChats = 2
    }
    
    // MARK:- Properties
    
    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
        
    let defaultCustomerChatCredentials = Credentials(withCompany: "vs-dev", userToken: "vs-cct-c6", isCustomer: true, targetCustomerToken: nil)
    let defaultRepChatCredentials = Credentials(withCompany: "vs-dev", userToken: "vs-cct", isCustomer: false, targetCustomerToken: "vs-cct-c6")
    
    let customerChatCredentials = [
        Credentials(withCompany: "vs-dev", userToken: "vs-cct-c6", isCustomer: true, targetCustomerToken: nil),
        Credentials(withCompany: "vs-dev", userToken: "vs-cct-c7", isCustomer: true, targetCustomerToken: nil),
        Credentials(withCompany: "vs-dev", userToken: "vs-cct-c8", isCustomer: true, targetCustomerToken: nil),
        Credentials(withCompany: "vs-dev", userToken: "vs-cct-c9", isCustomer: true, targetCustomerToken: nil),
        Credentials(withCompany: "vs-dev", userToken: "vs-cct-c10", isCustomer: true, targetCustomerToken: nil)
    ]
    let repChatCredentials = [Credentials(withCompany: "vs-dev", userToken: "vs-cct", isCustomer: false, targetCustomerToken: "vs-cct-c6")]
    
    // MARK:- Init
    
    func commonInit() {
        title = "Test Chats"
        automaticallyAdjustsScrollViewInsets = true
        
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
    
    // MARK:- Status Bar
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

extension ChatsListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return ChatSection.TwoWayChats.rawValue + 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let chatSection: ChatSection = ChatSection(rawValue: section) else { return 0 }
        
        switch chatSection {
        case .CustomerChats: return customerChatCredentials.count
        case .RepChats: return repChatCredentials.count
        case .TwoWayChats: return 1
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let chatSection: ChatSection = ChatSection(rawValue: section) else { return nil }
        
        switch chatSection {
        case .CustomerChats: return "Customer Chats"
        case .RepChats: return "Rep Chats"
        case .TwoWayChats: return "Two-Way Chats"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = "cellReuseId"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) ?? UITableViewCell(style: .Default, reuseIdentifier: reuseId)
        
        cell.textLabel?.font = UIFont.systemFontOfSize(16)
        cell.accessoryType = .DisclosureIndicator
        
        if let chatSection = ChatSection(rawValue: indexPath.section) {
            switch chatSection {
            case .CustomerChats:
                let conversation = customerChatCredentials[indexPath.row]
                cell.textLabel?.text = conversation.description
                break
                
            case .RepChats:
                let conversation = repChatCredentials[indexPath.row]
                cell.textLabel?.text = conversation.description
                break
                
            case .TwoWayChats:
                cell.textLabel?.text = "Rep: \(defaultRepChatCredentials.userToken ?? "") <-> Customer: \(defaultCustomerChatCredentials.userToken ?? "")"
                break
            }
        }
        
        return cell
    }
}

extension ChatsListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        guard let chatSection: ChatSection = ChatSection(rawValue: indexPath.section) else { return }
        
        var chatCredentials: Credentials?
        
        switch chatSection {
        case .CustomerChats:
            chatCredentials = customerChatCredentials[indexPath.row]
            break
            
        case .RepChats:
            chatCredentials = repChatCredentials[indexPath.row]
            break
            
        case .TwoWayChats:
            let chatViewController = TwoWayChatViewController(withLeftChatCredentials: defaultRepChatCredentials, rightChatCredentials: defaultCustomerChatCredentials)
            chatViewController.title = "Two-Way Chat"
            navigationController?.pushViewController(chatViewController, animated: true)
            break
        }
        
        if let chatCredentials = chatCredentials {
            let chatViewController = ASAPP.createChatViewController(withCredentials: chatCredentials)
            chatViewController.title = chatCredentials.description
            navigationController?.pushViewController(chatViewController, animated: true)
        }
    }
}
