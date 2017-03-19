//
//  ComponentsDemoViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ComponentsDemoViewController: UIViewController {

    var componentNames: [String]? {
        didSet {
            tableView.reloadData()
        }
    }

    let tableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK: Properties: First Responder
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: Init
    
    func commonInit() {
        title = "Component UI"
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ComponentsDemoViewController.refresh))
        
        tableView.backgroundColor = ASAPP.styles.backgroundColor2
        tableView.separatorColor = ASAPP.styles.separatorColor1
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
        
        view.backgroundColor = ASAPP.styles.backgroundColor2
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
        
        var contentInset = UIEdgeInsets.zero
        if let navBar = navigationController?.navigationBar {
            contentInset.top = navBar.frame.maxY
        }
        tableView.contentInset = contentInset
    }
    
    // MARK: Content
    
    func refresh() {
        becomeFirstResponder()
        DemoComponents.getComponentNames { [weak self]  (componentNames) in
            Dispatcher.performOnMainThread {
                self?.componentNames = componentNames
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

// MARK:- UITableViewDataSource

extension ComponentsDemoViewController: UITableViewDataSource {
    
    func getComponentName(for indexPath: IndexPath) -> String? {
        guard let componentNames = componentNames,
            indexPath.row < componentNames.count else {
                return nil
        }
        return componentNames[indexPath.row]
    }
    
    func getPrettyComponentName(for indexPath: IndexPath) -> String? {
        guard let name = getComponentName(for: indexPath) else {
            return nil
        }
        return name.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return componentNames?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "NameReuseId"
        let cell = (tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .value1, reuseIdentifier: reuseId))
   
        cell.backgroundColor = ASAPP.styles.backgroundColor1
        cell.textLabel?.text = getPrettyComponentName(for: indexPath)
        cell.textLabel?.textColor = ASAPP.styles.foregroundColor1
        cell.textLabel?.font = ASAPP.styles.font(with: .regular, size: 16)
        
        return cell
    }
}

// MARK:- UITableViewDelegate

extension ComponentsDemoViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let componentName = getComponentName(for: indexPath) {
            let previewVC = ComponentPreviewViewController()
            previewVC.componentName = componentName
            navigationController?.pushViewController(previewVC, animated: true)
        }
    }
}
