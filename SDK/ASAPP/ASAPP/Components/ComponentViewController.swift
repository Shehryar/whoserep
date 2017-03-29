//
//  ComponentViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol ComponentViewControllerDelegate: class {
    func componentViewController(_ viewController: ComponentViewController,
                                 didTapAPIAction action: APIAction,
                                 with data: [String : Any]?,
                                 completion: @escaping ((_ nextAction: ComponentAction?, _ error: String?) -> Void))
    
    func componentViewController(_ viweController: ComponentViewController,
                                 fetchContentForViewNamed viewName: String,
                                 completion: @escaping ((ComponentViewContainer?, /* error */String?) -> Void))
}

class ComponentViewController: UIViewController {
    
    // MARK: Properties
    
    var componentViewContainer: ComponentViewContainer? {
        didSet {
            title = componentViewContainer?.title
            rootView = componentViewContainer?.createView()
        }
    }
    
    weak var delegate: ComponentViewControllerDelegate?
    
    fileprivate(set) var isLoading: Bool = false {
        didSet {
            if isLoading {
                spinnerView.startAnimating()
            } else {
                spinnerView.stopAnimating()
            }
        }
    }
    
    fileprivate var rootView: ComponentView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            
            rootView?.interactionHandler = self
            
            if let rootView = rootView, isViewLoaded {
                view.addSubview(rootView.view)
                view.setNeedsLayout()
            }
        }
    }
    
    fileprivate let spinnerView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    fileprivate let componentName: String?
    
    // MARK: Init
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.asappCloseBarButtonItem(location: .chat,
                                                                                    side: .right,
                                                                                    target: self,
                                                                                    action: #selector(ComponentViewController.dismissAnimated))
        
        spinnerView.hidesWhenStopped = true
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
        
        // Navigation Bar
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.isTranslucent = true
            navigationBar.shadowImage = nil
            navigationBar.setBackgroundImage(nil, for: .default)
            navigationBar.setBackgroundImage(nil, for: .compact)
            navigationBar.backgroundColor = nil
            if ASAPP.styles.navBarBackgroundColor.isDark() {
                navigationBar.barStyle = .black
                if ASAPP.styles.navBarBackgroundColor != UIColor.black {
                    navigationBar.barTintColor = ASAPP.styles.navBarBackgroundColor
                }
            } else {
                navigationBar.barStyle = .default
                if ASAPP.styles.navBarBackgroundColor != UIColor.white {
                    navigationBar.barTintColor = ASAPP.styles.navBarBackgroundColor
                }
            }
            navigationBar.tintColor = ASAPP.styles.navBarButtonColor
            setNeedsStatusBarAppearanceUpdate()
        }
        view.backgroundColor = UIColor.white
        
        view.addSubview(spinnerView)
        
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
        
        var visibleTop: CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            visibleTop = navBar.frame.maxY
        }
        let visibleHeight = view.bounds.height - visibleTop
        spinnerView.sizeToFit()
        spinnerView.center = CGPoint(x: view.bounds.midX, y: visibleTop + floor(visibleHeight / 2.0))
    }
    
    func getRootViewFrame() -> CGRect {
        guard let rootView = rootView else {
            return .zero
        }
        
        var top: CGFloat = 0.0
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.maxY
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
        if let apiAction = buttonItem.action as? APIAction {
            handleAPIAction(apiAction, from: buttonView, with: buttonItem)
        } else if let componentViewAction = buttonItem.action as? ComponentViewAction {
            handleComponentViewAction(componentViewAction)
        } else if let finishAction = buttonItem.action as? FinishAction {
            handleFinishAction(finishAction)
        }
    }
}

// MARK:- Routing Actions

extension ComponentViewController {
    
    func handleAPIAction(_ action: APIAction, from buttonView: ButtonView, with buttonItem: ButtonItem) {
        guard let component = componentViewContainer?.root, let delegate = delegate else {
            return
        }
        
        var requestData = [String : Any]()
        requestData.add(action.data)
        requestData.add(component.getData(for: action.dataInputFields))
        
        buttonView.isLoading = true
        
        delegate.componentViewController(self,
                                         didTapAPIAction: action,
                                         with: requestData,
                                         completion: { [weak self] (nextAction, error) in
                                            
                                            buttonView.isLoading = false
                                            
                                            if let finishAction = nextAction as? FinishAction {
                                                self?.handleFinishAction(finishAction)
                                            } else if let viewAction = nextAction as? ComponentViewAction {
                                                self?.handleComponentViewAction(viewAction)
                                            }
        })
    }
    
    func handleComponentViewAction(_ action: ComponentViewAction) {
        let viewController = ComponentViewController(componentName: action.name)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func handleFinishAction(_ action: FinishAction) {
        dismiss(animated: true, completion: nil)
    }
}
