//
//  ComponentViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK: - ComponentViewControllerDelegate

protocol ComponentViewControllerDelegate: class {
    
    func componentViewController(_ viewController: ComponentViewController,
                                 didTapAPIAction action: APIAction,
                                 withFormData formData: [String: Any]?,
                                 completion: @escaping APIActionResponseHandler)
    
    func componentViewController(_ viewController: ComponentViewController,
                                 didTapHTTPAction action: HTTPAction,
                                 withFormData formData: [String: Any]?,
                                 completion: @escaping APIActionResponseHandler)
    
    func componentViewController(_ viewController: ComponentViewController,
                                 fetchContentForViewNamed viewName: String,
                                 withData data: [String: Any]?,
                                 completion: @escaping ((ComponentViewContainer?, /* error */String?) -> Void))
    
    func componentViewControllerDidFinish(with action: FinishAction?)
}

// MARK: - ComponentViewController

class ComponentViewController: ASAPPViewController, UpdatableFrames {
    
    // MARK: Properties
    
    var componentViewContainer: ComponentViewContainer? {
        didSet {
            title = componentViewContainer?.title
            rootView = componentViewContainer?.createView()
            updateTitleBar()
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
    
    private let titleBarHeight: CGFloat = 44
    
    private let titleBar = UIView()
    
    private let titleLabel = UILabel()
    
    private let closeButton = UIButton()
    
    private let viewName: String?
    
    private let viewData: [String: Any]?
    
    private let isInset: Bool
    
    // MARK: Init
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.rightBarButtonItem = NavCloseBarButtonItem(location: .chat, side: .right)
            .configSegue(.present)
            .configTarget(self, action: #selector(ComponentViewController.didTapNavigationCloseButton))
        
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
    
    init(viewName: String, viewData: [String: Any]?, isInset: Bool) {
        self.viewName = viewName
        self.viewData = viewData
        self.isInset = isInset
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewName = nil
        self.viewData = nil
        self.isInset = false
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewName = nil
        self.viewData = nil
        self.isInset = false
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
        
        titleLabel.textAlignment = .center
        let icon = Images.getImage(.iconX)
        closeButton.setImage(icon?.tinted(ASAPP.styles.colors.dark), for: .normal)
        closeButton.setImage(icon?.tinted(ASAPP.styles.colors.dark).withAlpha(0.5), for: .highlighted)
        closeButton.addTarget(self, action: #selector(didTapNavigationCloseButton), for: .touchUpInside)
        titleBar.addSubview(closeButton)
        titleBar.addSubview(titleLabel)
        let borderLayer = CALayer()
        borderLayer.backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15).cgColor
        borderLayer.frame = CGRect(x: 0, y: titleBarHeight, width: view.bounds.width, height: 1)
        titleBar.layer.addSublayer(borderLayer)
        view.addSubview(titleBar)
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
        var top: CGFloat = 0
        if let navigationBar = navigationController?.navigationBar,
            let navBarFrame = navigationBar.superview?.convert(navigationBar.frame, to: view) {
            let intersection = view.frame.intersection(navBarFrame)
            if !intersection.isNull {
                top = intersection.maxY
            }
        }
        
        let width = view.bounds.width
        
        if isInset {
            titleBar.frame = CGRect(x: 0, y: 0, width: width, height: titleBarHeight)
            let buttonSize = titleBarHeight
            closeButton.frame = CGRect(x: width - buttonSize, y: 0, width: buttonSize, height: buttonSize)
            titleLabel.frame = CGRect(x: buttonSize, y: 0, width: width - 2 * buttonSize, height: titleBarHeight)
            top = titleBar.frame.maxY
        }
        
        let height = view.bounds.height - top
        
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
    
    func showComponentView(named name: String, withData data: [String: Any]?, isInset: Bool) {
        let viewController = ComponentViewController(viewName: name, viewData: data, isInset: isInset)
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
    
    func updateTitleBar() {
        if isInset {
            titleBar.isHidden = false
        } else {
            titleBar.isHidden = true
        }
        
        titleLabel.setAttributedText(title, textType: .body2)
    }
}

// MARK: - InteractionHandler

extension ComponentViewController: InteractionHandler {
    
    func didTapButtonView(_ buttonView: ButtonView, with buttonItem: ButtonItem) {
        if let httpAction = buttonItem.action as? HTTPAction {
            handleHTTPAction(httpAction, from: buttonView, with: buttonItem)
        } else if let apiAction = buttonItem.action as? APIAction {
            handleAPIAction(apiAction, from: buttonView, with: buttonItem)
        } else if let componentViewAction = buttonItem.action as? ComponentViewAction {
            showComponentView(named: componentViewAction.name, withData: componentViewAction.data, isInset: componentViewAction.displayStyle == .inset)
        } else if let finishAction = buttonItem.action as? FinishAction {
            finish(with: finishAction)
        }
    }
}

// MARK: - ComponentViewContentHandler

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

// MARK: - Form Validation

extension ComponentViewController {
    @discardableResult
    func validateRequiredInputs() -> Bool {
        guard let root = componentViewContainer?.root else {
            return true
        }
        
        var emptyRequiredInputs = [String: String]()
        
        root.enumerateRequiredNestedComponents { component in
            guard let name = component.name else { return }
            
            if component.valueIsEmpty {
                emptyRequiredInputs[name] = ASAPP.strings.requiredFieldEmptyMessage
            }
        }
        
        if emptyRequiredInputs.isEmpty {
            return true
        }
        
        markInvalidInputs(emptyRequiredInputs)
        
        return false
    }
    
    func markInvalidInputs(_ invalidInputs: [String: String]) {
        rootView?.enumerateNestedComponentViews { componentView in
            if let component = componentView.component,
               let name = component.name,
               let errorMessage = invalidInputs[name],
               let input = componentView as? InvalidatableInput {
                input.updateError(for: errorMessage)
            }
        }
        
        rootView?.updateFrames()
    }
}

// MARK: - APIAction Handling

extension ComponentViewController {
    
    func handleAPIAction(_ action: APIAction, from buttonView: ButtonView, with buttonItem: ButtonItem) {
        guard let component = componentViewContainer?.root,
              let delegate = delegate,
              validateRequiredInputs() else {
            return
        }
        
        let data = component.getData()
        
        buttonView.isLoading = true
        
        delegate.componentViewController(
            self,
            didTapAPIAction: action,
            withFormData: data,
            completion: { [weak self] (response) in
                Dispatcher.performOnMainThread {
                    buttonView.isLoading = false
                    self?.handleAPIActionResponse(response)
                }
            })
    }
    
    func handleHTTPAction(_ action: HTTPAction, from buttonView: ButtonView, with buttonItem: ButtonItem) {
        guard let component = componentViewContainer?.root,
              let delegate = delegate,
              validateRequiredInputs() else {
            return
        }
        
        let data = component.getData()
        
        buttonView.isLoading = true
        
        delegate.componentViewController(
            self,
            didTapHTTPAction: action,
            withFormData: data,
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
                
            case .refreshView:
                if let viewContainer = response.view {
                    componentViewContainer = viewContainer
                }
                
            case .finish:
                finish(with: response.finishAction)
            }
            
        } else {
            handleAPIActionError(response?.error)
        }
    }
    
    func handleAPIActionError(_ error: APIActionError?) {
        if let error = error,
           let invalidInputs = error.invalidInputs,
           !invalidInputs.isEmpty {
            markInvalidInputs(invalidInputs)
        }
        
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
