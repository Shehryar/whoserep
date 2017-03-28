//
//  ComponentMessagePreviewViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/28/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentMessagePreviewViewController: UIViewController {

    var fileName: String? {
        didSet {
            refresh()
        }
    }
    
    var message: ChatMessage? {
        didSet {
            if let message = message {
                messagesView.reloadWithEvents([Event]())
                messagesView.addMessage(message)
            }
        }
    }
    
    // MARK:- Private Properties
    
    fileprivate let messagesView = ChatMessagesView()
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK:- Initialization
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        messagesView.overrideToHideInfoView = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(messagesView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        becomeFirstResponder()
    }
    
    // MARK:- Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var top: CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.maxY
        }
        let height = view.bounds.height - top
        messagesView.frame = CGRect(x: 0, y: top, width: view.bounds.width, height: height)
    }
    
    // MARK:- Refresh
    
    func refresh() {
        guard let fileName = fileName else {
            return
        }
        
        DemoComponentsAPI.getChatMessage(with: fileName) { [weak self] (message, err) in
            Dispatcher.performOnMainThread {
                self?.message = message
            }
        }
    }
    
    // MARK: Motion
    
    public override func motionEnded(_ motion: UIEventSubtype,
                                     with event: UIEvent?) {
        if motion == .motionShake {
            refresh()
        }
    }
}
