//
//  TwoWayChatViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 7/28/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

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
        
        
//        let leftChatStyles = ASAPPStyles.darkStyles()
        

        
        self.leftChatCredentials = leftChatCredentials
        self.rightChatCredentials = rightChatCredentials
        self.leftChatViewController = UIViewController() //SRS.createChatViewController(withCredentials: self.leftChatCredentials, styles: leftChatStyles, callback: { (action, userInfo) in })
        
        
        self.rightChatViewController = UIViewController() //ASAPP.createChatViewController(withCredentials: self.rightChatCredentials, styles: nil, callback: { (action, userInfo) in })
    
        super.init(nibName: nil, bundle: nil)
        
        dividerView.backgroundColor = UIColor(red:0.919,  green:0.883,  blue:0.840, alpha:1)
        
        labelsContainer.backgroundColor = UIColor.clear
        labelsContainer.layer.shadowColor = UIColor.black.cgColor
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
    
    func applyStylesToLabel(_ label: UILabel) {
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(red:0.210,  green:0.674,  blue:0.643, alpha:1)
        label.textAlignment = .center
        label.clipsToBounds = false
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftChatViewController.willMove(toParentViewController: self)
        view.addSubview(leftChatViewController.view)
        
        rightChatViewController.willMove(toParentViewController: self)
        view.addSubview(rightChatViewController.view)
        
        labelsContainer.addSubview(leftChatTitleLabel)
        labelsContainer.addSubview(rightChatTitleLabel)
        view.addSubview(labelsContainer)
        view.addSubview(dividerView)
    }

    // MARK:- Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // TODO: Fix this later when we need it
    }
}
