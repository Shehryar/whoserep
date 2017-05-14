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
                                 completion: @escaping APIActionResponseHandler)
    
    func componentViewController(_ viewController: ComponentViewController,
                                 fetchContentForViewNamed viewName: String,
                                 completion: @escaping ((ComponentViewContainer?, /* error */String?) -> Void))
}

class ComponentViewController: ASAPPViewController, UpdatableFrames {
    
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
    
        view.backgroundColor = ASAPP.styles.colors.backgroundPrimary
        
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
        let top: CGFloat = 0.0
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
            showComponentView(named: componentViewAction.name)
        } else if let finishAction = buttonItem.action as? FinishAction {
            finish()
        }
    }
}

extension ComponentViewController: ComponentViewContentHandler {
    
    func componentView(_ componentView: ComponentView, didPageCarousel carousel: CarouselViewItem) {
        
    }

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
    
    func handleAPIActionError(_ error: APIActionError?) {
        
    }
    
    func handleAPIAction(_ action: APIAction, from buttonView: ButtonView, with buttonItem: ButtonItem) {
        guard let component = componentViewContainer?.root, let delegate = delegate else {
            return
        }
        
        var requestData = [String : Any]()
        requestData.add(action.data)
        requestData.add(component.getData())
        
        buttonView.isLoading = true
        
        delegate.componentViewController(self,
                                         didTapAPIAction: action,
                                         with: requestData,
                                         completion: { [weak self] (response) in
                                            buttonView.isLoading = false
                                            
                                            if let response = response, response.type != .error {
                                                switch response.type {
                                                case .error:
                                                    // Handled in if statement
                                                    break
                                                    
                                                case .componentView:
                                                    self?.showComponentView(response.view)
                                                    break
                                                    
                                                case .refreshView:
                                                    self?.refreshView(with: response.view)
                                                    break
                                                    
                                                case .finish:
                                                    self?.finish()
                                                    break
                                                }
                                                
                                            } else {
                                                self?.handleAPIActionError(response?.error)
                                            }
        })
    }
    
    func refreshView(with componentViewContainer: ComponentViewContainer?) {
        guard let componentViewContainer = componentViewContainer else {
            return
        }
        
        
    }
    
    func showComponentView(_ view: ComponentViewContainer? = nil, named name: String? = nil) {
        guard view != nil || name != nil else {
            DebugLog.d(caller: self, "Must pass view or name")
            return
        }
        
        var viewController: ComponentViewController?
        if let view = view {
//            viewController =
        } else if let name = name {
            viewController = ComponentViewController(componentName: name)
        }
        
        viewController?.delegate = delegate
        if let viewController = viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func finish() {
        dismiss(animated: true, completion: nil)
    }
}
