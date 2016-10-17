//
//  ImageBackgroundViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 8/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ImageBackgroundViewController: UIViewController {

    let imageView = UIImageView()
    
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    // MARK:- Initialization
    
    func commonInit() {
        
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

        imageView.contentMode = .scaleToFill
        view.addSubview(imageView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var top: CGFloat = 0.0
        if let navController = navigationController {
            top = navController.navigationBar.frame.maxY
        }
        let height = view.bounds.height - top
        imageView.frame = CGRect(x: 0.0, y: top, width: view.bounds.width, height: height)
    }
}
