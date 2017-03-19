//
//  ComponentViewDemoViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ComponentViewDemoViewController: UIViewController {
    
    var demoComponent: DemoComponent? {
        didSet {
            title = demoComponent?.rawValue
            refresh()
        }
    }
    
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
    
    fileprivate let contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    // MARK: Properties: First Responder
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: Init
    
    func commonInit() {
        containerView.backgroundColor = ASAPP.styles.backgroundColor2
        containerView.layer.borderColor = ASAPP.styles.separatorColor2.cgColor
        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 12
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
        
        becomeFirstResponder()
        demoComponent = .stackView
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
    }
    
    // MARK: Content
    
    func refresh() {
        DebugLog.i(caller: self, "Refreshing UI")
        
        guard let demoComponent = demoComponent else {
            DebugLog.w(caller: self, "No demo component to refresh with.")
            return
        }
        
        DemoComponents.getComponent(for: demoComponent) { [weak self] (component, error) in
            
            if let component = component {
                Dispatcher.performOnMainThread {
                    self?.contentView = ComponentViewFactory.view(withComponent: component)
                }
            }
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
