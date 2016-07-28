//
//  TwoWayChatViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 7/28/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP
import SnapKit

class TwoWayChatViewController: UIViewController {

    var leftChatViewController: UIViewController
    var rightChatViewController: UIViewController
    
    var leftChatTitleLabel = UILabel()
    var rightChatTitleLabel = UILabel()
    var dividerView = UIView()
    
    var leftChatCredentials: Credentials
    var rightChatCredentials: Credentials
    
    // MARK:- Init
    
    required init(withLeftChatCredentials leftChatCredentials: Credentials, rightChatCredentials: Credentials) {
        self.leftChatCredentials = leftChatCredentials
        self.rightChatCredentials = rightChatCredentials
        self.leftChatViewController = ASAPP.createChatViewController(withCredentials: self.leftChatCredentials)
        self.rightChatViewController = ASAPP.createChatViewController(withCredentials: self.rightChatCredentials)
    
        super.init(nibName: nil, bundle: nil)
        
        dividerView.backgroundColor = UIColor.lightGrayColor()
        
        leftChatTitleLabel.text = leftChatCredentials.description
        leftChatTitleLabel.font = UIFont.boldSystemFontOfSize(14)
        leftChatTitleLabel.textColor = UIColor.whiteColor()
        leftChatTitleLabel.backgroundColor = UIColor(red:0.139,  green:0.576,  blue:0.975, alpha:1)
        leftChatTitleLabel.textAlignment = .Center
        
        rightChatTitleLabel.text = rightChatCredentials.description
        rightChatTitleLabel.font = UIFont.boldSystemFontOfSize(14)
        rightChatTitleLabel.textColor = UIColor.whiteColor()
        rightChatTitleLabel.backgroundColor = UIColor(red:0.139,  green:0.576,  blue:0.975, alpha:1)
        rightChatTitleLabel.textAlignment = .Center
        
        addChildViewController(leftChatViewController)
        addChildViewController(rightChatViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftChatViewController.willMoveToParentViewController(self)
        view.addSubview(leftChatViewController.view)
        
        rightChatViewController.willMoveToParentViewController(self)
        view.addSubview(rightChatViewController.view)
        
        view.addSubview(leftChatTitleLabel)
        view.addSubview(rightChatTitleLabel)
        view.addSubview(dividerView)
    }

    // MARK:- Layout
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }
    
    override func updateViewConstraints() {
        
        leftChatTitleLabel.snp_updateConstraints { (make) in
            if let navigationController = navigationController {
                make.top.equalTo(navigationController.navigationBar.snp_bottom)
            } else {
                make.top.equalTo(view.snp_top)
            }
            make.left.equalTo(leftChatViewController.view.snp_left)
            make.width.equalTo(leftChatViewController.view.snp_width)
            make.height.equalTo(40)
        }
        
        rightChatTitleLabel.snp_updateConstraints { (make) in
            make.top.equalTo(leftChatTitleLabel.snp_top)
            make.right.equalTo(rightChatViewController.view.snp_right)
            make.width.equalTo(rightChatViewController.view.snp_width)
            make.height.equalTo(leftChatTitleLabel.snp_height)
        }
        
        leftChatViewController.view.snp_updateConstraints { (make) in
            make.top.equalTo(leftChatTitleLabel.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.bottom.equalTo(view.snp_bottom)
            make.width.equalTo(rightChatViewController.view.snp_width)
            make.right.equalTo(rightChatViewController.view.snp_left)
        }
        
        rightChatViewController.view.snp_updateConstraints { (make) in
            make.top.equalTo(rightChatTitleLabel.snp_bottom)
            make.left.equalTo(leftChatViewController.view.snp_right)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(view.snp_bottom)
        }
        
        dividerView.snp_updateConstraints { (make) in
            make.left.equalTo(leftChatViewController.view.snp_right)
            make.top.equalTo(view.snp_top)
            make.bottom.equalTo(view.snp_bottom)
            make.width.equalTo(1)
        }
        
        super.updateViewConstraints()
    }

}
