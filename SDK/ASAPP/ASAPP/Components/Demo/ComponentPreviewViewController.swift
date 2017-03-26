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
            title = DemoComponentsAPI.prettifyComponentName(componentName)
            refresh()
        }
    }

    var componentViewContainer: ComponentViewContainer?
    
    var json: [String : Any]?
    
    // MARK: Private Properties
    
    fileprivate(set) var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let contentView = contentView, isViewLoaded {
                view.addSubview(contentView)
            }
        }
    }
    
    var componentView: ComponentView? {
        if let componentContentView = contentView as? ComponentView {
            return componentContentView
        } else if let componentCardView = contentView as? ComponentCardView {
            return componentCardView.componentView
        }
        return nil
    }
    
    fileprivate let controlsBar = UIToolbar()
    
    fileprivate let contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    // MARK: Properties: First Responder
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: Init
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        controlsBar.barStyle = .default
        controlsBar.items = [
            UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(ComponentPreviewViewController.start)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "View Source", style: .plain, target: self, action: #selector(ComponentPreviewViewController.viewSource))
        ]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ComponentPreviewViewController.refresh))
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    // MARK: View
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ASAPP.styles.backgroundColor2
        if let contentView = contentView {
            view.addSubview(contentView)
        }
        view.addSubview(controlsBar)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    // MARK: Layout
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let contentView = contentView else {
            return
        }
        
        var top: CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.maxY
        }
        
        let controlBarHeight: CGFloat = ceil(controlsBar.sizeThatFits(CGSize(width: view.bounds.width, height: 0)).height)
        let controlBarTop: CGFloat = view.bounds.height - controlBarHeight
        controlsBar.frame = CGRect(x: 0, y: controlBarTop, width: view.bounds.width, height: controlBarHeight)
        
        var contentWidth = view.bounds.width
        var contentBottom = controlsBar.frame.minY
        var contentLeft: CGFloat = 0
        var contentTop = top
        if contentView is ComponentCardView {
            contentLeft = contentInset.left
            contentWidth -= contentInset.left + contentInset.right
            contentTop += contentInset.top
            contentBottom -= contentInset.bottom
        }
        let contentHeight = contentBottom - top
        var size = contentView.sizeThatFits(CGSize(width: contentWidth, height: contentHeight))
        size.height = ceil(size.height)
        size.width = ceil(size.width)
        
        contentView.frame = CGRect(x: contentLeft, y: contentTop, width: size.width, height: size.height)
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
            guard let strongSelf = self else {
                return
            }
            
            self?.componentViewContainer = component
            self?.json = json
            
            if let component = component {
                Dispatcher.performOnMainThread {
                    switch DemoComponentsAPI.getDemoComponentType(from: componentName) {
                    case .card:
                        var cardView = ComponentCardView()
                        cardView.component = component.root
                        cardView.interactionHandler = self
                        self?.contentView = cardView
                        self?.view.backgroundColor = ASAPP.styles.backgroundColor2
                        break
                        
                    case .view:
                        var componentView = component.root.createView()
                        componentView?.interactionHandler = strongSelf
                        self?.contentView = componentView?.view
                        self?.view.backgroundColor = ASAPP.styles.backgroundColor1
                        break
                    }
                    
                    self?.view.setNeedsLayout()
                }
            }
        }
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
    
    func start() {
        guard let componentViewContainer = componentViewContainer else {
            return
        }
        
        let viewController = ComponentViewController()
        viewController.componentViewContainer = componentViewContainer
        let navController = ComponentNavigationController(rootViewController: viewController)
        navController.useCustomPresentation = true
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: Motion
    
    public override func motionEnded(_ motion: UIEventSubtype,
                                     with event: UIEvent?) {
        if motion == .motionShake {
            refresh()
        }
    }
}

// MARK:- InteractionHandler

extension ComponentPreviewViewController: InteractionHandler {
    
    func didTapButtonView(_ buttonView: ButtonView, with buttonItem: ButtonItem) {
        guard let action = buttonItem.action else {
            let alert = UIAlertController(title: "No Action", message: "This button does not have an action attached to it", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        switch action.type {
        case .api:
            handleAPIAction(action, from: buttonItem)
            break
            
        case .componentView:
            handleComponentViewAction(action, from: buttonItem)
            break
            
        case .finish:
            handleFinishAction(action, from: buttonItem)
            break
        }
    }
}

// MARK:- Routing Actions

extension ComponentPreviewViewController {
    
    func handleAPIAction(_ action: ComponentAction, from buttonItem: ButtonItem) {
        guard let component = componentViewContainer?.root else {
            return
        }
        
        var requestData = component.getData(for: buttonItem.action?.dataInputFields)
        requestData.add(buttonItem.action?.data)
    
        let requestDataString = JSONUtil.stringify(requestData as? AnyObject,
                                                   prettyPrinted: true)
        
        let title = buttonItem.action?.requestPath ?? buttonItem.action?.type.rawValue ?? "Oops?"
        
        let alert = UIAlertController(title: title,
                                      message: requestDataString,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func handleComponentViewAction(_ action: ComponentAction, from buttonItem: ButtonItem) {
        guard let componentName = action.name else {
            return
        }
        
        let viewController = ComponentViewController(componentName: componentName)
        let navigationController = ComponentNavigationController(rootViewController: viewController)
        navigationController.useCustomPresentation = true
        present(navigationController, animated: true, completion: nil)
    }
    
    func handleFinishAction(_ action: ComponentAction, from buttonItem: ButtonItem) {
        let alert = UIAlertController(title: "Finish Action", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
