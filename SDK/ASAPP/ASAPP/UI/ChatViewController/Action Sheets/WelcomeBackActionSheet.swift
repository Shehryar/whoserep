//
//  WelcomeBackActionSheet.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 2/9/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class WelcomeBackActionSheet: BaseActionSheet {
    init(for continuePrompt: ContinuePrompt) {
        super.init(title: continuePrompt.title, body: continuePrompt.body, hideButtonTitle: continuePrompt.continueText, restartButtonTitle: continuePrompt.abandonText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
