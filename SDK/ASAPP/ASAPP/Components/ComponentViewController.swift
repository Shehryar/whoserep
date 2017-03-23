//
//  ComponentViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentViewController: UIViewController {

    // MARK: Properties
    
    var componentViewContainer: ComponentViewContainer? {
        didSet {
            title = componentViewContainer?.title
            rootView = componentViewContainer?.createView()
        }
    }
    
    fileprivate var rootView: ComponentView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            
            rootView?.interactionHandler = self
            
            if let rootView = rootView, isViewLoaded {
                view.addSubview(rootView.view)
            }
        }
    }
    
    fileprivate let componentName: String?
    
    // MARK: Init
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.circleCloseBarButtonItem(foregroundColor: ASAPP.styles.navBarButtonForegroundColor, backgroundColor: ASAPP.styles.navBarButtonBackgroundColor, target: self, action: #selector(ComponentViewController.dismissAnimated))
    }
    
    init(componentName: String) {
        self.componentName = componentName
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.componentName = nil
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.componentName = nil
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    deinit {
         rootView?.interactionHandler = nil
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        if let rootView = rootView {
            view.addSubview(rootView.view)
        } else {
            refreshView()
        }
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        rootView?.view.frame = getRootViewFrame()
    }
    
    func getRootViewFrame() -> CGRect {
        guard let rootView = rootView else {
            return .zero
        }
        
        var top: CGFloat = 0.0
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.intersection(view.frame).height
        }
        let maxHeight = view.bounds.height - top
        let maxWidth = view.bounds.width
        let size = rootView.view.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
        
        return CGRect(x: 0, y: top, width: size.width, height: size.height)
    }
    
    // MARK: Instance Methods
    
    func dismissAnimated() {
        dismiss(animated: true, completion: nil)
    }
    
    func refreshView() {
        guard let componentName = componentName else {
            return
        }
        
        DemoComponentsAPI.getComponent(with: componentName) { (componentViewContainer, json, error) in
            Dispatcher.performOnMainThread { [weak self] in
                self?.componentViewContainer = componentViewContainer
            }
        }
    }
}

// MARK:- InteractionHandler

extension ComponentViewController: InteractionHandler {
    
    func didTapButtonView(_ buttonView: ButtonView, with buttonItem: ButtonItem) {
        guard let action = buttonItem.action else {
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

extension ComponentViewController {
    
    func handleAPIAction(_ action: ComponentAction, from buttonItem: ButtonItem) {
        
    }
    
    func handleComponentViewAction(_ action: ComponentAction, from buttonItem: ButtonItem) {
        guard let componentName = action.name else {
            return
        }
        
        let viewController = ComponentViewController(componentName: componentName)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func handleFinishAction(_ action: ComponentAction, from buttonItem: ButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
