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
    
    enum ChatStyle {
        case Light
        case Dark
    }
    
    // MARK:- Properties
    
    var defaultChatStyle = ChatStyle.Light {
        didSet {
            if oldValue != defaultChatStyle {
                updateToggleButtonTitle()
            }
        }
    }
    
    var toggleButtonItem: UIBarButtonItem?
    
    let chatButton1 = ASAPPButton()
    
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
        
        chatButton1.presentingViewController = self
        chatButton1.credentials = defaultCustomerChatCredentials
        chatButton1.hideUntilAnimateInIsCalled()
        
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        
        toggleButtonItem = UIBarButtonItem(title: "Toggle Button", style: .Plain, target: self, action: #selector(ChatsListViewController.didToggleDefaultStyle))
        updateToggleButtonTitle()
        navigationItem.rightBarButtonItem = toggleButtonItem
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
        view.addSubview(chatButton1)
        
        view.setNeedsUpdateConstraints()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        chatButton1.animateIn(afterDelay: 1)
    }
    
    // MARK:- Layout
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        chatButton1.snp_updateConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.right.equalTo(view.snp_right).offset(-15)
            make.bottom.equalTo(view.snp_bottom).offset(-15)
        }
    }
    
    // MARK:- Status Bar
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK:- Toggling Styles
    
    func didToggleDefaultStyle() {
        switch defaultChatStyle {
        case .Light:
            self.defaultChatStyle = .Dark
            break
            
        case .Dark:
            self.defaultChatStyle = .Light
            break
        }
    }
    
    func updateToggleButtonTitle() {
        switch defaultChatStyle {
        case .Light:
            toggleButtonItem?.title = "Default Style: Light"
            break
            
        case .Dark:
            toggleButtonItem?.title = "Default Style: Dark"
            break
        }
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
            switch self.traitCollection.horizontalSizeClass {
            case .Compact:
                showAlert(withTitle: "Not Supported!", message: "Two-way chat requires a large amount of screen space to function properly and is not supported for your current screen size.")
                break
                
            case .Regular:
                let chatViewController = TwoWayChatViewController(withLeftChatCredentials: defaultRepChatCredentials, rightChatCredentials: defaultCustomerChatCredentials)
                chatViewController.title = "Two-Way Chat"
                navigationController?.pushViewController(chatViewController, animated: true)
                break
                
            case .Unspecified:
                showAlert(withTitle: "Unspecified Trait Class...", message: "Email mitch@asapp.com and let him know how you got here.")
                break
            }
            break
        }
        
        if let chatCredentials = chatCredentials {
            var styles: ASAPPStyles
            switch defaultChatStyle {
            case .Light:
                styles = ASAPPStyles()
                break
                
            case .Dark:
                styles = ASAPPStyles.darkStyles()
                break
            }
            let chatViewController = ASAPP.createChatViewController(withCredentials: chatCredentials, styles: styles)
            chatViewController.title = chatCredentials.description
            navigationController?.pushViewController(chatViewController, animated: true)
        }
    }
}

extension ChatsListViewController {
    func showAlert(withTitle title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}
