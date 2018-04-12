//
//  ContinuePrompt.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 2/9/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation
/*
 title?    String text to be used as the header of the prompt.
 text    String message which is used to prompt the user to abandon or continue.
 continueText String message to be shown on the continue button.
 abandonText    String message to be shown on the abandon button.
 */

class ContinuePrompt {
    let title: String?
    let body: String
    let continueText: String
    let abandonText: String
    
    init(title: String?, body: String, continueText: String, abandonText: String) {
        self.title = title
        self.body = body
        self.continueText = continueText
        self.abandonText = abandonText
    }
}

extension ContinuePrompt {
    enum JSONKey: String {
        case title
        case text
        case continueText
        case abandonText
    }
    
    class func fromDict(_ dict: [String: Any]) -> ContinuePrompt? {
        guard let body = dict.string(for: JSONKey.text.rawValue) else {
            DebugLog.w(caller: self, "ContinuePrompt missing text")
            return nil
        }
        
        guard let continueText = dict.string(for: JSONKey.continueText.rawValue) else {
            DebugLog.w(caller: self, "ContinuePrompt missing continueText")
            return nil
        }
        
        guard let abandonText = dict.string(for: JSONKey.abandonText.rawValue) else {
            DebugLog.w(caller: self, "ContinuePrompt missing abandonText")
            return nil
        }
        
        let title = dict.string(for: JSONKey.title.rawValue)
        
        return ContinuePrompt(title: title, body: body, continueText: continueText, abandonText: abandonText)
    }
}
