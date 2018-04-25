//
//  LoginViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 7/11/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class LoginViewController: OptionsForKeyViewController {

    var onUserSelection: (() -> Void)?
    
    var onCancel: (() -> Void)?
    
    var dismissOnUserSelection: Bool = true
    
    override func commonInit() {
        super.commonInit()
        
        title = "Log In"
        randomEntryPrefix = "test-user-"
        update(selectedOptionKey: AppSettings.Key.customerIdentifier,
               optionsListKey: AppSettings.Key.customerIdentifierList)
        
        onSelection = { [weak self] customerIdentifier in
            if let customerIdentifier = customerIdentifier {
                self?.userDidLogin(customerIdentifier)
            }
        }
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !canNavigateBack() {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                               target: self,
                                                               action: #selector(LoginViewController.didTapCancel))
        }
    }
    
    fileprivate func userDidLogin(_ customerIdentifier: String) {
        onUserSelection?()
        
        if dismissOnUserSelection {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func didTapCancel() {
        onCancel?()
        
        dismiss(animated: true, completion: nil)
    }
}
