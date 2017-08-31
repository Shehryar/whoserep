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
        createCustomOptionTitle = "Create Custom User"
        createRandomOptionTitle = "Create Random User"
        randomEntryPrefix = "test-user-"
        deleteSelectedOptionTitle = "Use Anonymous User"
        update(selectedOptionKey: AppSettings.Key.customerIdentifier,
               optionsListKey: AppSettings.Key.customerIdentifierList)
    }
}
