//
//  ComponentCardsPreviewViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentCardsPreviewViewController: UIViewController {

    var componentNames: [String]? {
        didSet {
            guard let componentNames = componentNames, componentNames.count > 0 else {
                return
            }
            
            DemoComponentsAPI.getComponents(with: componentNames) { [weak self] (componentViewContainers) in
                var components = [Component]()
                for viewContainer in componentViewContainers {
                    components.append(viewContainer.root)
                }
                
                Dispatcher.performOnMainThread({ 
                    self?.components = components
                })
            }
        }
    }
    
    var components: [Component]? {
        didSet {
            for subview in scrollView.subviews {
                subview.removeFromSuperview()
            }
            
            if let components = components {
                for component in components {
                    var cardView = ComponentCardView()
                    cardView.interactionHandler = self
                    cardView.component = component
                    scrollView.addSubview(cardView)
                }
            }
            
            view.setNeedsLayout()
        }
    }
    
    fileprivate let contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    fileprivate let scrollView = UIScrollView()
    
    // MARK:- Initialization
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        scrollView.showsVerticalScrollIndicator = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ASAPP.styles.backgroundColor2
        view.addSubview(scrollView)
    }

    // MARK:- Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Scroll View
        var scrollViewTop: CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            scrollViewTop = navBar.frame.maxY
        }
        let height = view.bounds.height - scrollViewTop
        scrollView.frame = CGRect(x: 0, y: scrollViewTop, width: view.bounds.width, height: height)
        
        // Cards
        let contentWidth = view.bounds.width - contentInset.left - contentInset.right
        let left = contentInset.left
        var cardTop = contentInset.top
        for subview in scrollView.subviews {
            let size = subview.sizeThatFits(CGSize(width: contentWidth, height: 0))
            subview.frame = CGRect(x: left, y: cardTop, width: size.width, height: size.height)
            
            cardTop = subview.frame.maxY + contentInset.top
        }
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: cardTop)
    }
}


// MARK:- InteractionHandler

extension ComponentCardsPreviewViewController: InteractionHandler {
    
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

extension ComponentCardsPreviewViewController {
    
    func handleAPIAction(_ action: ComponentAction, from buttonItem: ButtonItem) {
        let alert = UIAlertController(title: "API Action",
                                      message: "Not handled on this screen",
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
