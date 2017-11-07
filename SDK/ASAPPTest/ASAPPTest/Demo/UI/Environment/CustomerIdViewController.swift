//
//  CustomerIdViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 8/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class CustomerIdViewController: OptionsForKeyViewController {
    var onTapClearSavedSession: (() -> Void)?
    
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

extension CustomerIdViewController {
    override func numberOfCreateNewRows() -> Int {
        return super.numberOfCreateNewRows() + 1
    }
    
    override func titleForCreateNewRow(_ row: Int) -> String? {
        switch row {
        case numberOfCreateNewRows() - 1:
            return "Clear Saved Session"
        default:
            return super.titleForCreateNewRow(row)
        }
    }
    
    override func performActionForCreateNewRow(_ row: Int) {
        switch row {
        case numberOfCreateNewRows() - 1:
            onTapClearSavedSession?()
        default:
            return super.performActionForCreateNewRow(row)
        }
    }
}
