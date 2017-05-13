//
//  RadioButtonsContainerView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonsContainerView: _RootComponentWrapperView {
    
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
    }
    
    func didTap(_ radioButtonView: RadioButtonView) {
        guard let radioButtonViews = radioButtonViews,
            radioButtonViews.contains(radioButtonView) else {
                return
        }
        
        if radioButtonView.isSelected {
            radioButtonView.isSelected = false
            component?.value = nil
        } else {
            radioButtonView.isSelected = true
            component?.value = radioButtonView.component?.value
            
            for otherRadioButtonView in radioButtonViews {
                if otherRadioButtonView != radioButtonView {
                    otherRadioButtonView.isSelected = false
                }
            }
        }
        
        DebugLog.d("Updated radio button value to \(component?.value ?? "nil")")
        
        contentHandler?.componentView(self,
                                      didUpdateContent: component?.value,
                                      requiresLayoutUpdate: false)
    }
    
}
