//
//  RestartConfirmationActionSheet.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 2/5/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class RestartConfirmationActionSheet: BaseActionSheet {
    init() {
        super.init(title: ASAPP.strings.restartConfirmationTitle, body: ASAPP.strings.restartConfirmationBody, hideButtonTitle: ASAPP.strings.restartConfirmationHideButton, restartButtonTitle: ASAPP.strings.restartConfirmationRestartButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
