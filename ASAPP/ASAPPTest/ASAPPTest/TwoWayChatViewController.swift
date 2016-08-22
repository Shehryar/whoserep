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
    var labelsContainer = UIView()
    var dividerView = UIView()
    
    var leftChatCredentials: Credentials
    
    
    var rightChatCredentials: Credentials
    
    // MARK:- Init
    
    required init(withLeftChatCredentials leftChatCredentials: Credentials, rightChatCredentials: Credentials) {

        assert(leftChatCredentials.targetCustomerToken == rightChatCredentials.userToken ||
            rightChatCredentials.targetCustomerToken == leftChatCredentials.userToken , "Target customer token must be the user token of the other party")
        
        
        let leftChatStyles = ASAPPStyles.darkStyles()
        

        
        self.leftChatCredentials = leftChatCredentials
        self.rightChatCredentials = rightChatCredentials
        self.leftChatViewController = ASAPP.createChatViewController(withCredentials: self.leftChatCredentials, styles: leftChatStyles, callback: { (action, userInfo) in })
        self.rightChatViewController = ASAPP.createChatViewController(withCredentials: self.rightChatCredentials, styles: nil, callback: { (action, userInfo) in })
    
        super.init(nibName: nil, bundle: nil)
        
        dividerView.backgroundColor = UIColor(red:0.919,  green:0.883,  blue:0.840, alpha:1)
        
        labelsContainer.backgroundColor = UIColor.clearColor()
        labelsContainer.layer.shadowColor = UIColor.blackColor().CGColor
        labelsContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        labelsContainer.layer.shadowRadius = 2
        labelsContainer.layer.shadowOpacity = 0.2
        
        leftChatTitleLabel.text = leftChatCredentials.isCustomer ? "Customer" : "Rep"
        applyStylesToLabel(leftChatTitleLabel)
        
        rightChatTitleLabel.text = rightChatCredentials.isCustomer ? "Customer" : "Rep"
        applyStylesToLabel(rightChatTitleLabel)
        
        addChildViewController(leftChatViewController)
        addChildViewController(rightChatViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Display
    
    func applyStylesToLabel(label: UILabel) {
        label.font = UIFont.boldSystemFontOfSize(16)
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor(red:0.210,  green:0.674,  blue:0.643, alpha:1)
        label.textAlignment = .Center
        label.clipsToBounds = false
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftChatViewController.willMoveToParentViewController(self)
        view.addSubview(leftChatViewController.view)
        
        rightChatViewController.willMoveToParentViewController(self)
        view.addSubview(rightChatViewController.view)
        
        labelsContainer.addSubview(leftChatTitleLabel)
        labelsContainer.addSubview(rightChatTitleLabel)
        view.addSubview(labelsContainer)
        view.addSubview(dividerView)
    }

    // MARK:- Layout
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }
    
    override func updateViewConstraints() {
        
        labelsContainer.snp_updateConstraints { (make) in
            if let navigationController = navigationController {
                make.top.equalTo(navigationController.navigationBar.snp_bottom)
            } else {
                make.top.equalTo(view.snp_top)
            }
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.height.equalTo(40)
        }
        
        leftChatTitleLabel.snp_updateConstraints { (make) in
            make.top.equalTo(labelsContainer.snp_top)
            make.left.equalTo(labelsContainer.snp_left)
            make.bottom.equalTo(labelsContainer.snp_bottom)
            make.width.equalTo(leftChatViewController.view.snp_width)
        }
        
        rightChatTitleLabel.snp_updateConstraints { (make) in
            make.top.equalTo(labelsContainer.snp_top)
            make.right.equalTo(labelsContainer.snp_right)
            make.bottom.equalTo(labelsContainer.snp_bottom)
            make.width.equalTo(rightChatViewController.view.snp_width)
        }
        
        leftChatViewController.view.snp_updateConstraints { (make) in
            make.top.equalTo(labelsContainer.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.bottom.equalTo(view.snp_bottom)
            make.width.equalTo(rightChatViewController.view.snp_width)
            make.right.equalTo(rightChatViewController.view.snp_left)
        }
        
        rightChatViewController.view.snp_updateConstraints { (make) in
            make.top.equalTo(labelsContainer.snp_bottom)
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
