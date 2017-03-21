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
    case progressBar = "progress_bar"
    case separator = "separator"
    
    // Templates
    case basicListItem = "basic_list_item"
    case stackView = "stack_view"
}

// MARK:- Component+ComponentType

extension Component where Self: Any {
    
    var componentType: ComponentType? {
        switch self {
        case is ButtonItem: return .button
        case is IconItem: return .icon
        case is LabelItem: return .label
        case is ProgressBarItem: return .progressBar
        case is SeparatorItem: return .separator
        
        case is BasicListItem: return .basicListItem
        case is StackViewItem: return .stackView
        
        default: return nil
        }
    }
}
