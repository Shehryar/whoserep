//
//  ComponentType.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// Maintain alphabetical order within sections
enum ComponentType: String {
    
    // Core Components
    case button = "button"
    case icon = "icon"
    case label = "label"
    case progressBar = "progressBar"
    case separator = "separator"
    case textInput = "textInput"
    
    // Templates
    case stackView = "stackView"
    
    // MARK: Utility
    
    func getItemClass() -> Component.Type {
        switch self {
        // Core Components
        case .button:        return ButtonItem.self
        case .icon:          return IconItem.self
        case .label:         return LabelItem.self
        case .progressBar:   return ProgressBarItem.self
        case .separator:     return SeparatorItem.self
        case .textInput:     return TextInputItem.self
            
        // Templates
        case .stackView:     return StackViewItem.self
        }
    }
}
