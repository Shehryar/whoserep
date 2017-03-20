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
    
    fileprivate var contentView: ComponentView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            
            if let contentView = contentView {
                containerView.addSubview(contentView.view)
                
                if isViewLoaded {
                    view.setNeedsLayout()
                }
            }
        }
    }
    
    fileprivate let containerView = UIView()
    
    fileprivate let controlsBar = UIToolbar()
    
    fileprivate let contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    // MARK: Properties: First Responder
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: Init
    
    func commonInit() {
        containerView.backgroundColor = ASAPP.styles.backgroundColor1
        containerView.layer.borderColor = ASAPP.styles.separatorColor1.cgColor
        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 5
        
        controlsBar.barStyle = .default
        controlsBar.items = [
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
        
        view.backgroundColor = UIColor.white
        view.addSubview(containerView)
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
        var height: CGFloat = 0
        var width: CGFloat = 0
        if let contentView = contentView {
            let size = contentView.view.sizeThatFits(CGSize(width: contentWidth, height: 0))
            height = ceil(size.height)
            width = ceil(size.width)
        }
        
        containerView.frame = CGRect(x: contentInset.left, y: top,
                                     width: width, height: height)
        contentView?.view.frame = containerView.bounds
        
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
        
        DemoComponents.getComponent(with: componentName) { [weak self] (component, json, error) in
            self?.json = json
            if let component = component {
                Dispatcher.performOnMainThread {
                    self?.contentView = ComponentViewFactory.view(withComponent: component)
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
    
    // MARK: Motion
    
    public override func motionEnded(_ motion: UIEventSubtype,
                                     with event: UIEvent?) {
        if motion == .motionShake {
            refresh()
        }
    }
}
