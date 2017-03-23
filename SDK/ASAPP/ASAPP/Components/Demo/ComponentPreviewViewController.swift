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
            UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(ComponentPreviewViewController.beginIneractions)),
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
            
            self?.json = json
            if let component = component {
                Dispatcher.performOnMainThread {
                    switch DemoComponentsAPI.getDemoComponentType(from: componentName) {
                    case .card:
                        var cardView = ComponentCardView()
                        cardView.component = component.root
                        cardView.interactionHandler = self
                        self?.contentView = cardView
                        break
                        
                    case .view:
                        var componentView = component.root.createView()
                        componentView?.interactionHandler = strongSelf
                        self?.contentView = componentView?.view
                        break
                    }
                    
                    
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
        let navigationController = UINavigationController(rootViewController: viewController)
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
                if let (name, value) = componentView?.getNameValue(for: inputField) {
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
