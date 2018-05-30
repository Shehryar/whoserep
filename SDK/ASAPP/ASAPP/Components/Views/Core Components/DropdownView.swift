//
//  DropdownView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 12/12/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import Foundation

class DropdownView: BaseComponentView {
    
    let textInputView = PlaceholderTextInputView()
    
    private lazy var icon: UIImageView = {
        return UIImageView(image: Images.getImage(.iconDropdownChevron)?.tinted(ASAPP.styles.colors.textPrimary))
    }()
    
    private var choice: Int?
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            choice = nil
            
            if let dropdownItem = dropdownItem {
                textInputView.placeholderText = dropdownItem.placeholder
                textInputView.font = ASAPP.styles.textStyles.style(for: dropdownItem.style.textType).font
            } else {
                textInputView.placeholderText = nil
            }
            
            textInputView.textColor = dropdownItem?.style.color ?? ASAPP.styles.colors.textPrimary
            textInputView.underlineColorDefault = ASAPP.styles.colors.controlSecondary
            textInputView.underlineStrokeWidth = 1
            textInputView.autocorrectionType = .no
            textInputView.autocapitalizationType = .none
            textInputView.isSecureTextEntry = false
            textInputView.characterLimit = nil
            textInputView.isRequired = false
        }
    }
    
    var dropdownItem: DropdownItem? {
        return component as? DropdownItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        textInputView.tintColor = .clear
        textInputView.onBeginEditing = onTap
        addSubview(textInputView)
        
        addSubview(icon)
    }
    
    override func updateFrames() {
        guard let component = component else {
            return
        }
        
        let iconSize = icon.image?.size ?? CGSize(width: 16, height: 16)
        let padding = component.style.padding
        
        textInputView.frame = UIEdgeInsetsInsetRect(bounds, padding)
        
        let iconLeft = textInputView.frame.maxX - iconSize.width
        let iconTop = textInputView.frame.maxY - textInputView.contentInset.bottom - textInputView.underlineStrokeWidth - textInputView.underlineMarginTop - iconSize.height
        icon.frame = CGRect(x: iconLeft, y: iconTop, width: iconSize.width, height: iconSize.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let component = component else {
            return .zero
        }
        
        let padding = component.style.padding
        
        let fitToWidth = max(0, (size.width > 0 ? size.width : CGFloat.greatestFiniteMagnitude) - padding.left - padding.right)
        let fitToHeight = max(0, (size.height > 0 ? size.height : CGFloat.greatestFiniteMagnitude) - padding.top - padding.bottom)
        guard fitToWidth > 0 && fitToHeight > 0 else {
            return .zero
        }
        
        let fittedSize = textInputView.sizeThatFits(CGSize(width: fitToWidth, height: fitToHeight))
        guard fittedSize.width > 0 && fittedSize.height > 0 else {
            return .zero
        }
        
        let fittedWidth = min(fitToWidth, fittedSize.width + padding.left + padding.right)
        let fittedHeight = min(fitToHeight, fittedSize.height + padding.top + padding.bottom)
        
        return CGSize(width: fittedWidth, height: fittedHeight)
    }
    
    @objc func onTap() {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        if let choice = choice {
            picker.selectRow(choice, inComponent: 0, animated: false)
        }
        textInputView.inputView = picker
        
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [space, doneButton, space]
        toolbar.sizeToFit()
        textInputView.inputToolbar = toolbar
    }
    
    @objc func done() {
        guard let picker = textInputView.inputView as? UIPickerView else {
            return
        }
        
        let index = picker.selectedRow(inComponent: 0)
        
        guard let option = dropdownItem?.options[index] else {
            return
        }
        
        choice = index
        dropdownItem?.value = option.value
        textInputView.text = option.text
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.textInputView.updateFrames()
        }
        textInputView.inputView = nil
        textInputView.inputToolbar = nil
        textInputView.reloadInputViews()
        textInputView.resignFirstResponder()
    }
}

extension DropdownView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dropdownItem?.options.count ?? 0
    }
}

extension DropdownView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dropdownItem?.options[row].text
    }
}
