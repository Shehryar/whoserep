//
//  ComponentViewDemoViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ComponentViewDemoViewController: UIViewController {
    
    var json: [String : Any]? {
        didSet {
            contentView = ComponentViewFactory.view(withJSON: json)
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
        
        contentView = DemoComponents.getComponentView(for: .stackView)
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
}
