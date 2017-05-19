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
    case checkbox = "checkbox"
    case checkboxView = "checkboxView"
    case icon = "icon"
    case label = "label"
    case pageControl = "pageControl"
    case progressBar = "progressBar"
    case radioButtonsContainer = "radioButtonsContainer"
    case radioButtonView = "radioButtonView"
    case radioButton = "radioButton"
    case separator = "separator"
    case slider = "slider"
    case textArea = "textArea"
    case textInput = "textInput"
    
    // Collections
    case carouselView = "carouselView"
    case scrollView = "scrollView"
    case stackView = "stackView"
    case tabView = "tabView"
    case tableView = "tableView"
    
    // MARK: Utility
    
    func getItemClass() -> Component.Type {
        switch self {
        // Core Components
        case .button: return ButtonItem.self
        case .checkbox: return CheckboxItem.self
        case .checkboxView: return CheckboxViewItem.self
        case .icon: return IconItem.self
        case .label: return LabelItem.self
        case .pageControl: return PageControlItem.self
        case .progressBar: return ProgressBarItem.self
        case .radioButtonView: return RadioButtonViewItem.self
        case .radioButtonsContainer: return RadioButtonsContainerItem.self
        case .radioButton: return RadioButtonItem.self
        case .separator: return SeparatorItem.self
        case .slider: return SliderItem.self
        case .textArea: return TextAreaItem.self
        case .textInput: return TextInputItem.self
            
        // Collections
        case .carouselView: return CarouselViewItem.self
        case .scrollView: return ScrollViewItem.self
        case .stackView: return StackViewItem.self
        case .tabView: return TabViewItem.self
        case .tableView: return TableViewItem.self
        }
    }
}
