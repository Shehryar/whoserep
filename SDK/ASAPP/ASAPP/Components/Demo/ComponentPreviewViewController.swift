//
//  ComponentPreviewViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ComponentPreviewViewController: UIViewController {
    
    var componentName: String? {
        didSet {
            title = componentName?.replacingOccurrences(of: "_", with: " ").capitalized
            refresh()
        }
    }
    
    var json: [String : Any]?
    
    // MARK: Private Properties
    
    let cardView = ComponentCardView()
    
    fileprivate let controlsBar = UIToolbar()
    
    fileprivate let contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    // MARK: Properties: First Responder
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: Init
    
    func commonInit() {
        controlsBar.barStyle = .default
        controlsBar.items = [
            UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(ComponentPreviewViewController.beginIneractions)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "View Source", style: .plain, target: self, action: #selector(ComponentPreviewViewController.viewSource))
        ]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ComponentPreviewViewController.refresh))
        
        cardView.interactionHandler = self
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
        cardView.interactionHandler = nil
    }
    
    // MARK: View
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ASAPP.styles.backgroundColor2
        view.addSubview(cardView)
        view.addSubview(controlsBar)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    // MARK: Layout
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var top: CGFloat = contentInset.top
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.maxY + contentInset.top
        }
        
        let contentWidth = view.bounds.width - contentInset.left - contentInset.right
        var size = cardView.sizeThatFits(CGSize(width: contentWidth, height: 0))
        size.height = ceil(size.height)
        size.width = ceil(size.width)
        
        cardView.frame = CGRect(x: contentInset.left, y: top, width: size.width, height: size.height)
        
        let controlBarHeight: CGFloat = ceil(controlsBar.sizeThatFits(CGSize(width: view.bounds.width, height: 0)).height)
        let controlBarTop: CGFloat = view.bounds.height - controlBarHeight
        controlsBar.frame = CGRect(x: 0, y: controlBarTop, width: view.bounds.width, height: controlBarHeight)
    }
    
    // MARK: Content
    
    func refresh() {
        becomeFirstResponder()
        DebugLog.i(caller: self, "Refreshing UI")
        
        guard let componentName = componentName else {
            DebugLog.w(caller: self, "No demo component to refresh with.")
            return
        }
        
        DemoComponentsAPI.getComponent(with: componentName) { [weak self] (component, json, error) in
            self?.json = json
            if let component = component {
                Dispatcher.performOnMainThread {
                    self?.cardView.component = component.root
                    self?.view.setNeedsLayout()
                }
            }
        }
    }
    
    func beginIneractions() {
        guard let componentName = componentName else {
            return
        }
        let viewController = ComponentViewController(componentName: componentName)
        let navigationController = NavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func viewSource() {
        if let jsonString = JSONUtil.stringify(json as? AnyObject, prettyPrinted: true) {
            let sourcePreviewVC = ComponentPreviewSourceViewController()
            sourcePreviewVC.json = jsonString
            navigationController?.pushViewController(sourcePreviewVC, animated: true)
        } else {
            let alertController = UIAlertController(title: "Source Unavailable", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                
            }))
            present(alertController, animated: true, completion: nil)
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

extension ComponentPreviewViewController: InteractionHandler {
    
    func didTapButtonView(_ buttonView: ButtonView, with buttonItem: ButtonItem) {
        var inputData = [String : Any]()
        if let inputFields = buttonItem.action?.dataInputFields {
            for inputField in inputFields {
                if let (name, value) = cardView.componentView?.getNameValue(for: inputField) {
                    inputData[name] = value
                }
            }
        }
        
        var requestData = [String : Any]()
        requestData.add(buttonItem.action?.data)
        requestData.add(inputData)
        let requestDataString = JSONUtil.stringify(requestData as? AnyObject,
                                                   prettyPrinted: true)
        
        let title = buttonItem.action?.requestPath ?? buttonItem.action?.type.rawValue ?? "Oops?"
        
        let alert = UIAlertController(title: title,
                                      message: requestDataString,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
