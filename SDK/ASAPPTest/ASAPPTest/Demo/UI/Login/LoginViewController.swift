//
//  LoginViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 7/11/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class LoginViewController: OptionsForKeyViewController {

    var onUserLogin: ((_ customerIdentifier: String?) -> Void)?
    
    var onCancel: (() -> Void)?
    
    var dismissOnUserLogin: Bool = true
    
    override func commonInit() {
        super.commonInit()
        
        title = "Log In"
        randomEntryPrefix = "test-user-"
        update(selectedOptionKey: AppSettings.Key.customerIdentifier,
               optionsListKey: AppSettings.Key.customerIdentifierList)
        
        onSelection = { [weak self] (customerIdentifier) in
            if let customerIdentifier = customerIdentifier {
                self?.userDidLogin(customerIdentifier)
            }
        }
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !canNavigateBack() {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                               target: self,
                                                               action: #selector(LoginViewController.didTapCancel))
        }
    }
    
    fileprivate func userDidLogin(_ customerIdentifier: String) {
        onUserLogin?(customerIdentifier)
        
        if dismissOnUserLogin {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func didTapCancel() {
        onCancel?()
        
        dismiss(animated: true, completion: nil)
    }
}
