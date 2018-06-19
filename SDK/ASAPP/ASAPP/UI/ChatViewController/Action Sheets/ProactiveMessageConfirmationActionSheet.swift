//
//  ProactiveMessageConfirmationActionSheet.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 6/11/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

protocol ProactiveMessageConfirmationActionSheetDelegate: class {
    func actionSheetDidTapConfirmWithButton(_ actionSheet: ProactiveMessageConfirmationActionSheet, button: QuickReply)
}

class ProactiveMessageConfirmationActionSheet: BaseActionSheet {
    weak var proactiveMessageDelegate: ProactiveMessageConfirmationActionSheetDelegate?
    
    private var button: QuickReply
    
    init(button: QuickReply) {
        self.button = button
        
        super.init(
            title: ASAPP.strings.proactiveMessageActionConfirmationTitle,
            body: ASAPP.strings.proactiveMessageActionConfirmationBody,
            hideButtonTitle: ASAPP.strings.proactiveMessageActionConfirmationCancel,
            restartButtonTitle: button.title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didTapConfirmButton() {
        proactiveMessageDelegate?.actionSheetDidTapConfirmWithButton(self, button: button)
    }
}
