//
//  UseCasePreviewViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class UseCasePreviewViewController: UIViewController {
    
    var useCases: [String] = [String]() {
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
        title = "Use Case Preview"
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
        
        var contentInset = UIEdgeInsets.zero
        if let navBar = navigationController?.navigationBar {
            contentInset.top = navBar.frame.maxY
        }
        tableView.contentInset = contentInset
    }
    
    // MARK: Content
    
    func refresh() {
        becomeFirstResponder()
        UseCasePreviewAPI.getUseCases { [weak self] (useCases, error) in
            if let useCases = useCases {
                self?.useCases = useCases
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

extension UseCasePreviewViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return useCases.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Use Cases"
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "NameReuseId"
        let cell = (tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId))
        
        cell.backgroundColor = ASAPP.styles.colors.backgroundPrimary
        
        let useCaseId = useCases[indexPath.row]
        cell.textLabel?.setAttributedText(DemoComponentType.prettifyFileName(useCaseId),
                                          textStyle: ASAPP.styles.textStyles.body)
        cell.detailTextLabel?.setAttributedText(DemoComponentType.fromFileName(useCaseId).rawValue,
                                                textStyle: ASAPP.styles.textStyles.detail1)
    
        return cell
    }
}

// MARK:- UITableViewDelegate

extension UseCasePreviewViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let useCaseId = useCases[indexPath.row]
        let type = DemoComponentType.fromFileName(useCaseId)
        switch type {
        case .view, .card:
            let previewVC = ComponentPreviewViewController()
            previewVC.useCaseId = useCaseId
            navigationController?.pushViewController(previewVC, animated: true)
            break
            
        case .message:
            let viewController = ComponentMessagePreviewViewController()
            viewController.useCaseId = useCaseId
            navigationController?.pushViewController(viewController, animated: true)
            break
        }
    }
}
