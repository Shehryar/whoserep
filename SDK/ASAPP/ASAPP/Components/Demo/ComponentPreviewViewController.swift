//
//  ComponentPreviewViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ComponentPreviewViewController: ASAPPViewController {
    
    var componentViewContainer: ComponentViewContainer?
    
    var json: [String : Any]?
    
    fileprivate(set) var classification: String?
    
    func setComponentViewContainer(_ viewContainer: ComponentViewContainer, with classification: String) {
        self.componentViewContainer = viewContainer
        self.classification = classification
        reloadView(with: viewContainer)
    }
    
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
        
        controlsBar.clipsToBounds = true
        controlsBar.barStyle = .default
        controlsBar.barTintColor = UIColor.white
        controlsBar.items = [
            UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(ComponentPreviewViewController.start)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
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
        
        view.clipsToBounds = true
        view.backgroundColor = ASAPP.styles.colors.backgroundSecondary
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
        view.bringSubview(toFront: controlsBar)
        
        guard let contentView = contentView else {
            return
        }
        
        let top: CGFloat = 0
        let controlBarHeight: CGFloat = 0//ceil(controlsBar.sizeThatFits(CGSize(width: view.bounds.width, height: 0)).height)
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
        size.height = min(contentHeight, ceil(size.height))
        size.width = min(contentWidth, ceil(size.width))
        
        contentView.frame = CGRect(x: contentLeft, y: contentTop, width: size.width, height: size.height)
    }
    
    // MARK: Content
    
    func reloadView(with componentViewContainer: ComponentViewContainer) {
        var componentType = DemoComponentType.view
        if let classification = classification,
            classification.contains("_card") && !classification.contains("credit_card") {
            componentType = .card
        }
        
        switch componentType {
        case .card:
            let cardView = ComponentCardView()
            cardView.component = componentViewContainer.root
            cardView.interactionHandler = self
            contentView = cardView
            view.backgroundColor = ASAPP.styles.colors.backgroundSecondary
            break
            
        case .view:
            var componentView = componentViewContainer.root.createView()
            componentView?.interactionHandler = self
            contentView = componentView?.view
            view.backgroundColor = ASAPP.styles.colors.backgroundPrimary
            break
            
        case .message:
            
            break
        }
        
        view.setNeedsLayout()
    }
    
    func refresh() {
        becomeFirstResponder()
        
        guard let classification = classification else {
             return
        }
        

        UseCasePreviewAPI.getTreewalk(with: classification, completion: { [weak self] (_, viewContainer, err) in
            if let viewContainer = viewContainer {
                self?.componentViewContainer = viewContainer
                self?.reloadView(with: viewContainer)
            } else {
                self?.showAlert(with: err ?? "Unable to refresh view")
            }
        })
    }
    
    func start() {
        guard let componentViewContainer = componentViewContainer else {
            return
        }
        
        let viewController = ComponentViewController()
        viewController.componentViewContainer = componentViewContainer
        let navController = ComponentNavigationController(rootViewController: viewController)
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: Motion
    
    public override func motionEnded(_ motion: UIEventSubtype,
                                     with event: UIEvent?) {
        if motion == .motionShake {
            refresh()
        }
    }
    
    // MARK: Instance Methods
    
    // MARK: Instance Methods
    
    func showAlert(title: String? = nil, with message: String?) {
        let alert = UIAlertController(title: title ?? "Oops!",
                                      message: message ?? "You messed up, bro",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK:- InteractionHandler

extension ComponentPreviewViewController: InteractionHandler {
    
    func didTapButtonView(_ buttonView: ButtonView, with buttonItem: ButtonItem) {
        if let apiAction = buttonItem.action as? APIAction {
            handleAPIAction(apiAction, from: buttonItem)
        } else if let componentViewAction = buttonItem.action as? ComponentViewAction {
            handleComponentViewAction(componentViewAction)
        } else if let finishAction = buttonItem.action as? FinishAction {
            handleFinishAction(finishAction)
        }
    }
}

// MARK:- Routing Actions

extension ComponentPreviewViewController {
    
    func handleAPIAction(_ action: APIAction, from buttonItem: ButtonItem) {
        guard let component = componentViewContainer?.root else {
            return
        }
        
        var requestData = action.data ?? [String : Any]()
        requestData.add(component.getData())
    
        let requestDataString = JSONUtil.stringify(requestData as AnyObject,
                                                   prettyPrinted: true)
        
        let title = action.requestPath
        
        let alert = UIAlertController(title: title,
                                      message: requestDataString,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func handleComponentViewAction(_ action: ComponentViewAction) {
        let viewController = ComponentViewController(componentName: action.name)
        viewController.delegate = self
        let navigationController = ComponentNavigationController(rootViewController: viewController)
        navigationController.displayStyle = action.displayStyle
        present(navigationController, animated: true, completion: nil)
    }
    
    func handleFinishAction(_ action: FinishAction) {
        let alert = UIAlertController(title: "Finish Action", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ComponentPreviewViewController: ComponentViewControllerDelegate {
    
    func componentViewControllerDidFinish(with action: FinishAction?) {
        dismiss(animated: true) { [weak self] in
            if let nextAction = action?.nextAction {
                let alert = UIAlertController(title: "nextAction: \(nextAction)", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func componentViewController(_ viweController: ComponentViewController,
                                 fetchContentForViewNamed viewName: String,
                                 completion: @escaping ((ComponentViewContainer?, String?) -> Void)) {
        
        UseCasePreviewAPI.getTreewalk(with: viewName, completion: { (_, componentViewContainer, err) in
            completion(componentViewContainer, err)
        })
    }
    
    func componentViewController(_ viewController: ComponentViewController,
                                 didTapAPIAction action: APIAction,
                                 withFormData formData: [String : Any]?,
                                 completion: @escaping APIActionResponseHandler) {
        let error = APIActionError(code: 500,
                                   userMessage: "Sorry, this feature is not supported in this view",
                                   debugMessage: "",
                                   invalidInputs: nil)
        
        completion(APIActionResponse(type: .error,
                                     view: nil,
                                     error: error))
        
    }
}

