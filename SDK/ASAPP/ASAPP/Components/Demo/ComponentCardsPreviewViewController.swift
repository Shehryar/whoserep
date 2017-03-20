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
            
            DemoComponentsAPI.getComponents(with: componentNames) { [weak self] (components) in
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
                    let cardView = ComponentCardView()
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
