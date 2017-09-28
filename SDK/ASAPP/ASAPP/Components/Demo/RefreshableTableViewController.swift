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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(RefreshableTableViewController.refresh))
        
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
        
        view.clipsToBounds = true
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
    
    @objc func refresh() {
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

// MARK: Alerts

extension RefreshableTableViewController {
    
    func showAlert(title: String? = nil, with message: String?) {
        let alert = UIAlertController(title: title ?? "Oops!",
                                      message: message ?? "You messed up, bro",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Showing a Preview

extension RefreshableTableViewController {
    
    func showPreview(for classification: String) {
        UseCasePreviewAPI.getTreewalk(with: classification) { [weak self] (message, viewContainer, error) in
            if let error = error {
                self?.showAlert(with: error)
                return
            }
            
            DebugLog.d("Received: message=\(message != nil), view=\(viewContainer != nil)")
            
            if let message = message {
                let viewController = ComponentMessagePreviewViewController()
                viewController.setMessage(message, with: classification)
                self?.navigationController?.pushViewController(viewController, animated: true)
            } else if let viewContainer = viewContainer {
                let previewVC = ComponentPreviewViewController()
                previewVC.setComponentViewContainer(viewContainer, with: classification)
                self?.navigationController?.pushViewController(previewVC, animated: true)
            } else {
                self?.showAlert(with: "Unable to determine contents of response. Please check that your JSON follows proper MitchML.")
            }
        }
    }
}
