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

class ComponentViewController: UIViewController, UpdatableFrames {
    
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
                emptyView.isHidden = true
                spinnerView.startAnimating()
            } else {
                spinnerView.stopAnimating()
                
                if rootView == nil {
                    emptyView.isHidden = false
                }
            }
        }
    }
    
    fileprivate var rootView: ComponentView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            
            rootView?.interactionHandler = self
            rootView?.contentHandler = self
            
            if let rootView = rootView, isViewLoaded {
                view.addSubview(rootView.view)
                view.setNeedsLayout()
            }
        }
    }
    
    fileprivate let spinnerView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    fileprivate let emptyView = ComponentViewEmptyReloadView()
    
    fileprivate let componentName: String?
    
    // MARK: Init
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.asappCloseBarButtonItem(location: .chat,
                                                                                    side: .right,
                                                                                    target: self,
                                                                                    action: #selector(ComponentViewController.dismissAnimated))
        
        emptyView.isHidden = true
        emptyView.onReloadButtonTap = { [weak self] in
            self?.refreshView()
        }
        emptyView.onCloseButtonTap = { [weak self] in
            self?.dismissAnimated()
            
        }
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
        rootView?.contentHandler = nil
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
        
        // Empty / Spinner View
        view.addSubview(spinnerView)
        view.addSubview(emptyView)
        
        // Root View
        if let rootView = rootView {
            view.addSubview(rootView.view)
        } else {
            refreshView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateFrames()
    }
    
    func updateFrames() {
        var top: CGFloat = 0.0
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.maxY
        }
        
        let height = view.bounds.height - top
        let width = view.bounds.width
        rootView?.view.frame = CGRect(x: 0, y: top, width: width, height: height)
        rootView?.updateFrames()
        
        let emptyViewSize = emptyView.sizeThatFits(CGSize(width: width, height: height))
        let emptyViewTop = top + floor((height - emptyViewSize.height) / 2.0)
        let emptyViewLeft = floor((width - emptyViewSize.width) / 2.0)
        emptyView.frame = CGRect(x: emptyViewLeft, y: emptyViewTop, width: emptyViewSize.width, height: emptyViewSize.height)
        
        spinnerView.sizeToFit()
        spinnerView.center = CGPoint(x: view.bounds.midX, y: top + floor(height / 2.0))
    }
    
    // MARK: Instance Methods
    
    func dismissAnimated() {
        dismiss(animated: true, completion: nil)
    }
    
    func refreshView() {
        guard let componentName = componentName,
            let delegate = delegate else {
                return
        }
        
        isLoading = true
        delegate.componentViewController(self, fetchContentForViewNamed: componentName) { [weak self] (componentViewContainer, error) in
            Dispatcher.performOnMainThread {
                self?.componentViewContainer = componentViewContainer
                self?.isLoading = false
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

extension ComponentViewController: ComponentViewContentHandler {
    
    func componentView(_ componentView: ComponentView,
                       didUpdateContent value: Any?,
                       requiresLayoutUpdate: Bool) {
        if requiresLayoutUpdate {
            updateFrames()
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
        viewController.delegate = delegate
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func handleFinishAction(_ action: FinishAction) {
        dismiss(animated: true, completion: nil)
    }
}
