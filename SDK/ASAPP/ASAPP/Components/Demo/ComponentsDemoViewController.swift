//
//  ComponentsDemoViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ComponentsDemoViewController: UIViewController {

    enum Section: Int {
        case previewAll
        case components
        case count
    }
    
    enum PreviewAllRows: Int {
        case cards
        case count
    }
    
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
            indexPath.section == Section.components.rawValue &&
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
        return Section.count.rawValue
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let componentsCount = componentNames?.count ?? 0
        switch section {
        case Section.previewAll.rawValue: return PreviewAllRows.count.rawValue
        case Section.components.rawValue: return componentsCount
        default: return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "NameReuseId"
        let cell = (tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .value1, reuseIdentifier: reuseId))
   
        cell.backgroundColor = ASAPP.styles.backgroundColor1
        cell.textLabel?.textColor = ASAPP.styles.foregroundColor1
        cell.textLabel?.font = ASAPP.styles.font(with: .regular, size: 16)
        
        switch indexPath.section {
        case Section.previewAll.rawValue:
            switch indexPath.row {
            case PreviewAllRows.cards.rawValue:
                cell.textLabel?.text = "All Cards"
                break
                
            default:
                break
            }
            break
            
        case Section.components.rawValue:
            cell.textLabel?.text = getPrettyComponentName(for: indexPath)
            break
            
        default:
            break
        }
        
        
        return cell
    }
}

// MARK:- UITableViewDelegate

extension ComponentsDemoViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case Section.previewAll.rawValue:
            showCardsPreview()
            break
            
        case Section.components.rawValue:
            showComponentPreview(for: getComponentName(for: indexPath))
            break
            
        default:
            break
        }
        
        if let componentName = getComponentName(for: indexPath) {
           
        }
    }
    
    func showCardsPreview() {
        guard let componentNames = componentNames else {
            let alert = UIAlertController(title: "No Cards to Preview", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: "Coming soon!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showComponentPreview(for name: String?) {
        guard let name = name else {
            return
        }
        
        let previewVC = ComponentPreviewViewController()
        previewVC.componentName = name
        navigationController?.pushViewController(previewVC, animated: true)
    }
}
