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
        case messages
        case cards
        case views
        case count
    }

    var componentNames: [String]? {
        didSet {
            messageNames.removeAll()
            cardNames.removeAll()
            viewNames.removeAll()
            if let componentNames = componentNames {
                for name in componentNames {
                    switch DemoComponentType.fromFileName(name) {
                    case .message:
                        messageNames.append(name)
                        break
                        
                    case .card:
                        cardNames.append(name)
                        break
                        
                    case .view:
                        viewNames.append(name)
                        break
                    }
                }
            }
            tableView.reloadData()
        }
    }
    fileprivate(set) var messageNames = [String]()
    fileprivate(set) var cardNames = [String]()
    fileprivate(set) var viewNames = [String]()

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
        DemoComponentsAPI.getComponentNames { [weak self]  (componentNames) in
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
        var sectionNames: [String]
        switch indexPath.section {
        case Section.messages.rawValue:
            sectionNames = messageNames
            break
        
        case Section.cards.rawValue:
            sectionNames = cardNames
            break
            
        case Section.views.rawValue:
            sectionNames = viewNames
            break
            
        default:
            sectionNames = [String]()
            break
        }
        
        guard indexPath.row < sectionNames.count else {
                return nil
        }
        
        return sectionNames[indexPath.row]
    }
    
    func getPrettyComponentName(for indexPath: IndexPath) -> String? {
        guard let name = getComponentName(for: indexPath) else {
            return nil
        }
        return DemoComponentType.prettifyFileName(name)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.messages.rawValue: return messageNames.count
        case Section.cards.rawValue: return cardNames.count > 0 ? cardNames.count + 1 : 0
        case Section.views.rawValue: return viewNames.count
        default: return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.messages.rawValue: return "Messages"
        case Section.cards.rawValue: return "Cards"
        case Section.views.rawValue: return "Views"
        default: return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "NameReuseId"
        let cell = (tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .value1, reuseIdentifier: reuseId))
   
        cell.backgroundColor = ASAPP.styles.backgroundColor1
        
        if let componentName = getPrettyComponentName(for: indexPath) {
            cell.textLabel?.text = componentName
            cell.textLabel?.font = ASAPP.styles.font(with: .regular, size: 16)
                cell.textLabel?.textColor = ASAPP.styles.foregroundColor1
        } else {
            cell.textLabel?.text = "All Cards"
            cell.textLabel?.font = ASAPP.styles.font(with: .black, size: 16)
            cell.textLabel?.textColor = ASAPP.styles.textButtonColor
        }
  
        return cell
    }
}

// MARK:- UITableViewDelegate

extension ComponentsDemoViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == Section.messages.rawValue {
            if let componentName = getComponentName(for: indexPath) {
                let viewController = ComponentMessagePreviewViewController()
                viewController.fileName = componentName
                viewController.allFileNames = componentNames
                navigationController?.pushViewController(viewController, animated: true)
            }
            return
        }
        
        if let componentName = getComponentName(for: indexPath) {
            showComponentPreview(for: componentName)
        } else {
            showCardsPreview(with: cardNames)
        }
    }
    
    func showCardsPreview(with names: [String]) {
        guard names.count > 0 else {
            let alert = UIAlertController(title: "No Cards to Preview", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let viewController = ComponentCardsPreviewViewController()
        viewController.componentNames = names
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showComponentPreview(for name: String) {
        let previewVC = ComponentPreviewViewController()
        previewVC.componentName = name
        navigationController?.pushViewController(previewVC, animated: true)
    }
}
