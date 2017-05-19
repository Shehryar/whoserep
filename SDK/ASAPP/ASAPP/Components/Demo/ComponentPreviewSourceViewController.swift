//
//  ComponentPreviewSourceViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentPreviewSourceViewController: UIViewController {

    var json: String? {
        didSet {
            textView.text = json
        }
    }
    
    fileprivate let textView = UITextView()
    
    // MARK:- Initialization
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = UIColor(red:0.004, green:0.024, blue:0.000, alpha:1.000)
        textView.textColor = UIColor(red:0.275, green:0.804, blue:0.129, alpha:1.000)
        textView.font = UIFont(name: "Menlo-Regular", size: 12)
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Copy Source", style: .plain, target: self, action: #selector(ComponentPreviewSourceViewController.copyAllText))
        
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
        
        view.backgroundColor = UIColor(red:0.004, green:0.024, blue:0.000, alpha:1.000)
        view.addSubview(textView)
    }
    
    // MARK:- Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var top: CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.maxY
        }
        let height = view.bounds.height - top
        textView.frame = CGRect(x: 0, y: top, width: view.bounds.width, height: height)
    }
    
    // MARK: Actions
    
    func copyAllText() {
        UIPasteboard.general.string = textView.text
        
        let alert = UIAlertController(title: "Source added to clipboard", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(ComponentPreviewViewController.selectAll(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func selectAll(_ sender: Any?) {
        textView.selectAll(sender)
    }
}
