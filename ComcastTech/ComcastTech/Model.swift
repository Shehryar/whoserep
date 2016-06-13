//
//  Model.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 6/8/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class Model: NSObject {
    
    // DUMMY CONTENT'
    static let optionDisct: [String: Bool] = [
        "Black Screen / One Moment Please": false
    ]
    static let content = StepModel.StepTypeMultiChoice(options: optionDisct, multiSelect: true)
    static let optionDisct2: [String: Bool] = [
        "Replaced Outside Drop": true,
        "Customer Edutcation": false
    ]
    static let content2 = StepModel.StepTypeMultiChoice(options: optionDisct2, multiSelect: true)
    // END DUMMY
    
    static var mCurrStep: Int = 0
    static var mContent: [StepModel.Step] = []
    
    static func dataForCurrentStep() -> StepModel.Step {
        return Model.mContent[Model.mCurrStep]
    }
    
    static func nextStep() {
        if Model.mContent.count - 1 > Model.mCurrStep {
            Model.mCurrStep += 1
        }
    }
    
    static func prevStep() {
        if Model.mCurrStep > 0 {
            Model.mCurrStep -= 1
        }
    }
    
    static func addStep(type: Type, title: String, content: Any, continueText: String) {
        let step = StepModel.Step(type: type, title: title, content: content, continueText: continueText)
        Model.mContent.append(step)
    }
    
    static func _init() {
        Model.addStep(.MultiChoice, title: "What is your issue?", content: content, continueText: "CONTINUE")
        Model.addStep(.MultiChoice, title: "How to fix it?", content: content2, continueText: "CONTINUE")
    }
    
}