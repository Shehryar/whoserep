//
//  CheckModel.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 5/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum Type: Int {
    case Intro = 1, MultiChoice, Confirm, Invalid
}

class StepModel: NSObject {
    
    struct StepTypeMultiChoice {
        var options: [String: Bool]
        var multiSelect: Bool
    }
    
    struct StepTypeConfirm {
        var confirmed: Bool
    }
    
    struct StepTypeIntro {
        var customerId: String
        var name: String
        var phone: String
        var address: String
        var issue: String
        var isConfirmed: String
    }
    
    class Step: NSObject {
        
        var type: Type!
        var title: String!
        var content: Any!
        var continueText: String!
        
        convenience init(type: Type, title: String, content: Any, continueText: String) {
            self.init()
            
            self.type = type
            self.title = title
            self.content = content
            self.continueText = continueText
        }
        
    }
    
}