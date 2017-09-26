//
//  ComponentViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- ComponentViewControllerDelegate

protocol ComponentViewControllerDelegate: class {
    
    func componentViewController(_ viewController: ComponentViewController,
                                 didTapAPIAction action: APIAction,
                                 withFormData formData: [String : Any]?,
                                 completion: @escaping APIActionResponseHandler)
    
    func componentViewController(_ viewController: ComponentViewController,
                                 fetchContentForViewNamed viewName: String,
                                 withData data: [String: Any]?,
                                 completion: @escaping ((ComponentViewContainer?, /* error */String?) -> Void))
    
    func componentViewControllerDidFinish(with action: FinishAction?)
}

// MARK:- ComponentViewController

class ComponentViewController: ASAPPViewController, UpdatableFrames {
    
    // MARK: Properties
    
    var componentViewContainer: ComponentViewContainer? {
        didSet {
            title = componentViewContainer?.title
            rootView = componentViewContainer?.createView()
        }
    }
    
    weak var delegate: ComponentViewControllerDelegate?
    
    private(set) var isLoading: Bool = false {
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
    
    private var rootView: ComponentView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            var mutableOldValue = oldValue
            mutableOldValue?.interactionHandler = nil
            mutableOldValue?.contentHandler = nil
            
            rootView?.interactionHandler = self
            rootView?.contentHandler = self
            
            if let rootView = rootView, isViewLoaded {
                view.addSubview(rootView.view)
                view.setNeedsLayout()
            }
        }
    }
    
    private let spinnerView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    private let emptyView = ComponentViewEmptyReloadView()
    
    private let viewName: String?
    
    private let viewData: [String: Any]?
    
    // MARK: Init
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.asappCloseBarButtonItem(
            location: .chat,
            target: self,
            action: #selector(ComponentViewController.didTapNavigationCloseButton))
        
        hideViewContentsWhileBackgrounded = true
        emptyView.isHidden = true
        emptyView.onReloadButtonTap = { [weak self] in
            self?.refreshView()
        }
        emptyView.onCloseButtonTap = { [weak self] in
            self?.finish(with: nil)
        }
        spinnerView.hidesWhenStopped = true
    }
    
    init(viewName: String, viewData: [String: Any]?) {
        self.viewName = viewName
        self.viewData = viewData
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewName = nil
        self.viewData = nil
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewName = nil
        self.viewData = nil
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
    
    func refreshView() {
        guard let viewName = viewName,
            let delegate = delegate else {
                return
        }
        
        isLoading = true
        delegate.componentViewController(self, fetchContentForViewNamed: viewName, withData: viewData) { [weak self] (componentViewContainer, _) in
            Dispatcher.performOnMainThread {
                self?.componentViewContainer = componentViewContainer
                self?.isLoading = false
            }
        }
    }
    
    func showComponentView(_ view: ComponentViewContainer) {
        let viewController = ComponentViewController()
        viewController.componentViewContainer = view
        viewController.delegate = delegate
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showComponentView(named name: String, withData data: [String: Any]?) {
        let viewController = ComponentViewController(viewName: name, viewData: data)
        viewController.delegate = delegate
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func didTapNavigationCloseButton() {
        finish(with: nil)
    }
    
    func finish(with action: FinishAction?) {
        if let delegate = delegate {
            delegate.componentViewControllerDidFinish(with: action)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK:- InteractionHandler

extension ComponentViewController: InteractionHandler {
    
    func didTapButtonView(_ buttonView: ButtonView, with buttonItem: ButtonItem) {
        if let apiAction = buttonItem.action as? APIAction {
            handleAPIAction(apiAction, from: buttonView, with: buttonItem)
        } else if let componentViewAction = buttonItem.action as? ComponentViewAction {
            showComponentView(named: componentViewAction.name, withData: componentViewAction.data)
        } else if let finishAction = buttonItem.action as? FinishAction {
            finish(with: finishAction)
        }
    }
}

// MARK:- ComponentViewContentHandler

extension ComponentViewController: ComponentViewContentHandler {
    
    func componentView(_ componentView: ComponentView, didPageCarousel carousel: CarouselViewItem) {}

    func componentView(_ componentView: ComponentView,
                       didUpdateContent value: Any?,
                       requiresLayoutUpdate: Bool) {
        if requiresLayoutUpdate {
            updateFrames()
        }
    }
}

// MARK:- APIAction Handling

extension ComponentViewController {
    
    func handleAPIAction(_ action: APIAction, from buttonView: ButtonView, with buttonItem: ButtonItem) {
        guard let component = componentViewContainer?.root, let delegate = delegate else {
            return
        }
        
        buttonView.isLoading = true
        
        delegate.componentViewController(self,
                                         didTapAPIAction: action,
                                         withFormData: component.getData(),
                                         completion: { [weak self] (response) in
                                            Dispatcher.performOnMainThread {
                                                buttonView.isLoading = false
                                                self?.handleAPIActionResponse(response)
                                            }
        })
    }
    
    func handleAPIActionResponse(_ response: APIActionResponse?) {
        if let response = response, response.type != .error {
            switch response.type {
            case .error:
                // Handled in if statement
                break
                
            case .componentView:
                if let view = response.view {
                    showComponentView(view)
                }
                break
                
            case .refreshView:
                if let viewContainer = response.view {
                    componentViewContainer = viewContainer
                }
                break
                
            case .finish:
                finish(with: response.finishAction)
                break
            }
            
        } else {
            handleAPIActionError(response?.error)
        }
    }
    
    func handleAPIActionError(_ error: APIActionError?) {
        let message = error?.userMessage ?? ASAPP.strings.requestErrorGenericFailure
        let alert = UIAlertController(title: ASAPP.strings.requestErrorGenericFailureTitle,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ASAPP.strings.alertDismissButton,
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
