//
//  RefreshableTableViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/8/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class RefreshableTableViewController: ASAPPViewController {

    let tableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK: Properties: First Responder
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: Init
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(UseCasePreviewViewController.refresh))
        
        tableView.backgroundColor = ASAPP.styles.colors.backgroundSecondary
        tableView.separatorColor = ASAPP.styles.colors.separatorPrimary
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK: View
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ASAPP.styles.colors.backgroundSecondary
        view.addSubview(tableView)
        
        refresh()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    // MARK: Layout
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    // MARK: Content
    
    func refresh() {
        // Subclass should override
    }
    
    // MARK: Motion
    
    public override func motionEnded(_ motion: UIEventSubtype,
                                     with event: UIEvent?) {
        if motion == .motionShake {
            refresh()
        }
    }
}

// MARK:- UITableViewDataSource

extension RefreshableTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
