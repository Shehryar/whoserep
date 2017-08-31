//
//  RadioButtonsContainerView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonsContainerView: RootComponentWrapperView {
    
    // MARK: Properties
    
    override var component: Component? {
        didSet {
            if let radioButtonsContainerItem = component as? RadioButtonsContainerItem {
                rootView = radioButtonsContainerItem.root.createView()?.view
            } else {
                rootView = nil
            }
            updateRadioButtonViews()
        }
    }
    
    var radioButtonViews: [RadioButtonView]?

    // MARK: 
    
    func updateRadioButtonViews() {
        guard let rootView = rootView as? ComponentView else {
            self.radioButtonViews = nil
            return
        }
        
        var radioButtonViews = [RadioButtonView]()
        rootView.enumerateNestedComponentViews { [weak self] (nestedView) -> Void in
            if let radioButtonView = nestedView as? RadioButtonView {
                radioButtonView.onTap = {
                    self?.didTap(radioButtonView)
                }
                radioButtonViews.append(radioButtonView)
            }
        }
        self.radioButtonViews = radioButtonViews
        updateRadioButtonStates()
    }
    
    func didTap(_ radioButtonView: RadioButtonView) {
        guard let radioButtonViews = radioButtonViews,
            radioButtonViews.contains(radioButtonView) else {
                return
        }
        
        // Deselect if already selected
        if radioButtonView.isSelected {
            component?.value = nil
        } else {
            component?.value = radioButtonView.component?.value
        }
        
        updateRadioButtonStates()
        
        DebugLog.d("Updated radio button value to \(component?.value ?? "nil")")
        
        contentHandler?.componentView(self,
                                      didUpdateContent: component?.value,
                                      requiresLayoutUpdate: false)
    }
    
    func updateRadioButtonStates() {
        guard let radioButtonViews = radioButtonViews,
            let component = component else {
                return
        }

        for radioButtonView in radioButtonViews {
            radioButtonView.isSelected = component.valueEquals(radioButtonView.component?.value)
        }
    }
    
}
