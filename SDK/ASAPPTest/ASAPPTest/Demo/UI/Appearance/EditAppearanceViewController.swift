//
//  EditAppearanceViewController.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 12/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit
import Photos

class EditAppearanceViewController: BaseTableViewController {
    enum Section: Int, CountableEnum {
        case name
        case logo
        case colors
        case strings
        case fontFamily
    }
    
    fileprivate(set) var name: String?
    
    fileprivate(set) var selectedLogo: Image
    fileprivate(set) var logoOptions: [(Image, UIColor)]
    fileprivate(set) var newLogo: Image?
    
    fileprivate(set) var selectedFontFamily: AppearanceConfig.FontFamilyName
    fileprivate(set) var fontFamilyOptions: DictionaryLiteral<AppearanceConfig.FontFamilyName, String> = [
        .asapp: "Lato",
        .boost: "Boost",
        .roboto: "Roboto"
    ]
    
    fileprivate(set) var allColors: DictionaryLiteral<AppearanceConfig.ColorName, String> = [
        .demoNavBar: "Demo nav bar",
        .brandPrimary: "Brand primary",
        .brandSecondary: "Brand secondary",
        .textLight: "Text light",
        .textDark: "Text dark"
    ]
    fileprivate(set) var colorSettings: [AppearanceConfig.ColorName: UIColor] = [:]
    fileprivate(set) var currentColor: AppearanceConfig.ColorName?
    
    fileprivate(set) var allStrings: DictionaryLiteral<AppearanceConfig.StringName, String> = [
        .helpButton: "Help button",
        .predictiveTitle: "Predictive title",
        .chatTitle: "Chat title"
    ]
    fileprivate(set) var stringSettings: [AppearanceConfig.StringName: String] = [:]
    
    fileprivate lazy var logoSizingCell = ImageCheckmarkCell()
    fileprivate lazy var buttonSizingCell = ButtonCell()
    fileprivate lazy var colorSizingCell = TitleImageCell()
    fileprivate lazy var textInputSizingCell = TextInputCell()
    fileprivate lazy var titleCheckmarkSizingCell = TitleCheckmarkCell()
    
    init() {
        name = AppSettings.shared.appearanceConfig.name
        selectedLogo = AppSettings.shared.appearanceConfig.logo
        logoOptions = AppSettings.getAppearanceConfigArray().map { ($0.logo, $0.getUIColor(.demoNavBar)) }
        selectedFontFamily = AppSettings.shared.appearanceConfig.fontFamilyName
        
        super.init(nibName: nil, bundle: nil)
        
        super.commonInit()
        
        title = "Appearance"
        
        tableView.register(ImageCheckmarkCell.self, forCellReuseIdentifier: ImageCheckmarkCell.reuseId)
        tableView.register(TitleImageCell.self, forCellReuseIdentifier: TitleImageCell.reuseId)
        
        for (colorName, _) in allColors {
            colorSettings[colorName] = AppSettings.shared.appearanceConfig.getUIColor(colorName)
        }
        
        for (stringName, _) in allStrings {
            stringSettings[stringName] = AppSettings.shared.appearanceConfig.strings[stringName]
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func save() {
        guard let name = name, !name.isEmpty else {
            showAlert(title: "Can't save appearance config", message: "You need to specify a name.")
            return
        }
        
        let logo = (newLogo?.id == selectedLogo.id) ? selectedLogo : Image(id: UUID().uuidString, uiImage: selectedLogo.uiImage)
        let config = AppearanceConfig(name: name, brand: .custom, logo: logo, colors: colorSettings.mapValues { Color(uiColor: $0)! }, strings: stringSettings, fontFamilyName: selectedFontFamily)
        AppSettings.addAppearanceConfigToArray(config)
        AppSettings.saveAppearanceConfig(config)
        AppSettings.shared.branding = Branding(appearanceConfig: config)
        navigationController?.popViewController(animated: true)
    }
}

extension EditAppearanceViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .some(.name):
            return 1
        case .some(.logo):
            let extra = (newLogo != nil) ? 2 : 1
            return logoOptions.count + extra
        case .some(.colors):
            return allColors.count
        case .some(.strings):
            return allStrings.count
        case .some(.fontFamily):
            return fontFamilyOptions.count
        case .none:
            return 0
        }
    }
    
    override func titleForSection(_ section: Int) -> String? {
        switch Section(rawValue: section) {
        case .some(.name):
            return ""
        case .some(.logo):
            return "Logo"
        case .some(.colors):
            return "Colors"
        case .some(.strings):
            return "Strings"
        case .some(.fontFamily):
            return "Font Family"
        case .none:
            return nil
        }
    }
    
    private func isChooseNewLogoRow(_ indexPath: IndexPath) -> Bool {
        let offset = (newLogo != nil) ? 1 : 0
        return indexPath.row == logoOptions.count + offset
    }
    
    private func isNewLogoRow(_ indexPath: IndexPath) -> Bool {
        if newLogo != nil {
            return indexPath.row == logoOptions.count
        }
        return false
    }
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .some(.name):
            return stringCell(text: name, placeholder: "Type a name", labelText: "Name", onTextChange: { [weak self] string in
                self?.name = string
            }, for: indexPath, sizingOnly: forSizing)
        case .some(.logo):
            if isChooseNewLogoRow(indexPath) {
                return buttonCell(title: "Choose new logo", for: indexPath, sizingOnly: forSizing)
            } else {
                let imageColorPair = isNewLogoRow(indexPath) ? (newLogo!, .white) : logoOptions[indexPath.row]
                let isChecked = isNewLogoRow(indexPath)
                    ? newLogo?.id == selectedLogo.id
                    : logoOptions[indexPath.row].0.id == selectedLogo.id
                return logoCheckmarkCell(imageColorPair: imageColorPair, isChecked: isChecked, for: indexPath, sizingOnly: forSizing)
            }
        case .some(.colors):
            return colorCell(colorName: allColors[indexPath.row].key, for: indexPath, sizingOnly: forSizing)
        case .some(.strings):
            let stringName = allStrings[indexPath.row].key
            return stringCell(text: stringSettings[stringName], labelText: allStrings[indexPath.row].value, onTextChange: { [weak self] string in
                self?.stringSettings[stringName] = string
            }, for: indexPath, sizingOnly: forSizing)
        case .some(.fontFamily):
            let (fontFamilyCase, fontFamilyString) = fontFamilyOptions[indexPath.row]
            return titleCheckMarkCell(title: fontFamilyString, fontFamily: fontFamilyCase, isChecked: fontFamilyCase == selectedFontFamily, for: indexPath, sizingOnly: forSizing)
        case .none:
            return UITableViewCell()
        }
    }
    
    func logoCheckmarkCell(imageColorPair: (Image, UIColor), isChecked: Bool, for indexPath: IndexPath, sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly ? logoSizingCell : tableView.dequeueReusableCell(withIdentifier: ImageCheckmarkCell.reuseId, for: indexPath) as? ImageCheckmarkCell
        
        let (image, color) = imageColorPair
        cell?.appSettings = AppSettings.shared
        cell?.customImage = image.uiImage
        cell?.backgroundColor = color
        cell?.isChecked = isChecked
        cell?.separatorInset = .zero
        
        return cell ?? UITableViewCell()
    }
    
    override func buttonCell(title: String?, loading: Bool = false, for indexPath: IndexPath, sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly ? buttonSizingCell : tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseId, for: indexPath) as? ButtonCell
        
        cell?.title = title
        cell?.titleLabel.font = AppearanceConfig.fontFamily(for: selectedFontFamily).medium.withSize(cell?.titleLabel.font.pointSize ?? 16)
        cell?.loading = loading
        
        return cell ?? UITableViewCell()
    }
    
    func colorCell(colorName: AppearanceConfig.ColorName, for indexPath: IndexPath, sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly ? colorSizingCell : tableView.dequeueReusableCell(withIdentifier: TitleImageCell.reuseId, for: indexPath) as? TitleImageCell
        
        let color = colorSettings[colorName] ?? .clear
        
        let rect: CGRect = CGRect(x: 0, y: 0, width: 34, height: 34)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.width, height: rect.height), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cell?.appSettings = AppSettings.shared
        cell?.title = allColors.first(where: { $0.0 == colorName })?.value ?? "?"
        cell?.titleLabel.font = AppearanceConfig.fontFamily(for: selectedFontFamily).regular.withSize(cell?.titleLabel.font.pointSize ?? 16)
        cell?.customImage = image
        cell?.customImageView.layer.cornerRadius = 17
        cell?.customImageView.layer.borderWidth = 1
        cell?.customImageView.layer.borderColor = color.isDark() ? color.cgColor : UIColor.black.cgColor
        cell?.customImageView.clipsToBounds = true
        
        return cell ?? UITableViewCell()
    }
    
    func stringCell(text: String?, placeholder: String? = nil, labelText: String?, onTextChange: ((String) -> Void)?, for indexPath: IndexPath, sizingOnly: Bool) -> TextInputCell {
        let cell = sizingOnly
            ? textInputSizingCell
            : tableView.dequeueReusableCell(withIdentifier: TextInputCell.reuseId, for: indexPath) as? TextInputCell
        
        cell?.appSettings = AppSettings.shared
        cell?.currentText = text ?? ""
        cell?.labelText = labelText
        cell?.textField.autocorrectionType = .no
        cell?.textField.returnKeyType = .done
        cell?.placeholderText = placeholder
        cell?.dismissKeyboardOnReturn = true
        cell?.onTextChange = onTextChange
        cell?.textFieldLabel.font = AppearanceConfig.fontFamily(for: selectedFontFamily).regular.withSize(cell?.textFieldLabel.font.pointSize ?? 16)
        cell?.textField.font = AppearanceConfig.fontFamily(for: selectedFontFamily).light.withSize(cell?.textField.font?.pointSize ?? 16)
        
        return cell ?? TextInputCell()
    }
    
    func titleCheckMarkCell(title: String?, fontFamily: AppearanceConfig.FontFamilyName, isChecked: Bool, for indexPath: IndexPath, sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? titleCheckmarkSizingCell
            : tableView.dequeueReusableCell(withIdentifier: TitleCheckmarkCell.reuseId, for: indexPath) as? TitleCheckmarkCell
        
        cell?.appSettings = AppSettings.shared
        cell?.title = title
        cell?.titleLabel.font = AppearanceConfig.fontFamily(for: fontFamily).regular.withSize(cell?.titleLabel.font.pointSize ?? 16)
        cell?.isChecked = isChecked
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Section(rawValue: indexPath.section) {
        case .some(.name):
            tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        case .some(.logo):
            if isChooseNewLogoRow(indexPath) {
                presentPhotoLibrary()
            } else {
                selectedLogo = isNewLogoRow(indexPath) ? newLogo! : logoOptions[indexPath.row].0
                tableView.reloadData()
            }
        case .some(.colors):
            currentColor = allColors[indexPath.row].key
            presentColorPicker()
        case .some(.strings):
            tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        case .some(.fontFamily):
            selectedFontFamily = fontFamilyOptions[indexPath.row].key
            tableView.reloadData()
        case .none:
            return
        }
    }
}

// MARK: - Picking a new logo image

extension EditAppearanceViewController {
    func presentPhotoLibrary() {
        let photoLibraryIsAvailable = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        guard photoLibraryIsAvailable else {
            showAlert(title: "Photo library not available")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
                
            case .notDetermined:
                self?.showAlert(title: "That's weird.", message: "Photo library authorization is still not determined.")
            case .restricted:
                self?.showAlert(title: "Can't access the photo library", message: "Access is restricted.")
            case .denied:
                self?.showAlert(title: "Please allow photo library access", message: "Go to the app's settings and authorize photo library access.")
            case .authorized:
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.allowsEditing = false
                imagePickerController.delegate = self
                self?.present(imagePickerController, animated: true, completion: nil)
            }
        }
    }
}

extension EditAppearanceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let scaledImage = image.scaled(to: CGSize(width: 230, height: 68))
            newLogo = Image(id: UUID().uuidString, uiImage: scaledImage)
            selectedLogo = newLogo!
            tableView.reloadData()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Editing a color

extension EditAppearanceViewController {
    func presentColorPicker() {
        guard let currentColor = currentColor else {
            return
        }
        
        let picker = ColorPickerViewController()
        picker.title = allColors.first { $0.key == currentColor }?.value
        picker.color = colorSettings[currentColor]
        picker.delegate = self
        navigationController?.pushViewController(picker, animated: true)
    }
}

extension EditAppearanceViewController: ColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: ColorPickerViewController, didFinishPickingColor color: UIColor?) {
        guard let currentColor = currentColor else {
            return
        }
        
        colorSettings[currentColor] = color
        tableView.reloadData()
    }
}
