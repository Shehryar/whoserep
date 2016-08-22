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
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.contentMode = .ScaleAspectFill
        view.addSubview(imageView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var top: CGFloat = 0.0
        if let navController = navigationController {
            top = CGRectGetMaxY(navController.navigationBar.frame)
        }
        let height = CGRectGetHeight(view.bounds) - top
        imageView.frame = CGRect(x: 0.0, y: top, width: CGRectGetWidth(view.bounds), height: height)
    }
}
