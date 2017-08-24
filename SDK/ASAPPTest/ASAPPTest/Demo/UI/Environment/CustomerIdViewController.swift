//
//  CustomerIdViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 8/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class CustomerIdViewController: OptionsForKeyViewController {

    override func commonInit() {
        super.commonInit()
        
        title = "Customer Id"
        randomEntryPrefix = "test-user-"
        update(selectedOptionKey: AppSettings.Key.customerIdentifier,
               optionsListKey: AppSettings.Key.customerIdentifierList)
        
        rightBarButtonItemTitle = "Anonymous"
        onRightBarButtonItemTap = { [weak self] in
            AppSettings.deleteObject(forKey: AppSettings.Key.customerIdentifier)
            self?.onSelection?(nil)
        }
    }
}
