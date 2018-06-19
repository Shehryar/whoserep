//
//  BaseTableViewController.swift
//  Analytics
//
//  Created by Mitchell Morgan on 10/19/16.
//  Copyright © 2016 ASAPP, Inc. All rights reserved.
//

import UIKit

class BaseTableViewController: BaseViewController {
    
    // MARK: - Properties
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK: - Sizing-Views
    
    fileprivate lazy var headerSizingView: TableHeaderView = {
        return TableHeaderView()
    }()

    // MARK: Sizing-Cells
    
    fileprivate lazy var buttonSizingCell: ButtonCell = {
        return ButtonCell()
    }()
    
    fileprivate lazy var imageNameSizingCell: ImageNameCell = {
        return ImageNameCell()
    }()
    
    fileprivate lazy var imageViewCarouselSizingCell: ImageViewCarouselCell = {
        return ImageViewCarouselCell()
    }()
    
    fileprivate lazy var labelIconSizingCell: LabelIconCell = {
        return LabelIconCell()
    }()
    
    fileprivate lazy var textInputSizingCell: TextInputCell = {
        return  TextInputCell()
    }()
    
    fileprivate lazy var titleCheckmarkSizingCell: TitleCheckmarkCell = {
        return TitleCheckmarkCell()
    }()
    
    fileprivate lazy var titleDetailValueSizingCell: TitleDetailValueCell = {
        return TitleDetailValueCell()
    }()
    
    // MARK: - Initialization
    
    override func commonInit() {
        super.commonInit()
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseId)
        tableView.register(ImageNameCell.self, forCellReuseIdentifier: ImageNameCell.reuseId)
        tableView.register(ImageViewCarouselCell.self, forCellReuseIdentifier: ImageViewCarouselCell.reuseId)
        tableView.register(LabelIconCell.self, forCellReuseIdentifier: LabelIconCell.reuseId)
        tableView.register(TextInputCell.self, forCellReuseIdentifier: TextInputCell.reuseId)
        tableView.register(TitleCheckmarkCell.self, forCellReuseIdentifier: TitleCheckmarkCell.reuseId)
        tableView.register(TitleDetailValueCell.self, forCellReuseIdentifier: TitleDetailValueCell.reuseId)
        
        tableView.backgroundColor = AppSettings.shared.branding.colors.secondaryBackgroundColor
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: Deinit
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deregisterForKeyboardNotifications()
    }
    
    // MARK: - Updates
    
    override func reloadViewForUpdatedSettings() {
        super.reloadViewForUpdatedSettings()
        
        tableView.backgroundColor = AppSettings.shared.branding.colors.secondaryBackgroundColor
        tableView.separatorColor = AppSettings.shared.branding.colors.separatorColor
        tableView.reloadData()
    }
    
    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
        
        guard #available(iOS 11, *) else {
            var insetTop: CGFloat = 0.0
            if let navBar = navigationController?.navigationBar {
                insetTop = navBar.frame.maxY
            }
            
            tableView.contentInset = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: insetTop, left: 0, bottom: 0, right: 0)
            tableView.contentOffset = CGPoint(x: 0, y: -tableView.contentInset.top)
            return
        }
    }
}

// MARK: - Convenience

extension BaseTableViewController {
    func focusOnCell(at indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
        tableView.scrollToRow(at: indexPath, at: .none, animated: true)
    }
}

// MARK: - Keyboard

extension BaseTableViewController {
    
    static let keyboardNotificationNames = [
        NSNotification.Name.UIKeyboardWillShow,
        NSNotification.Name.UIKeyboardWillChangeFrame,
        NSNotification.Name.UIKeyboardWillHide
    ]
    
    func registerForKeyboardNotifications() {
        for notificationName in BaseTableViewController.keyboardNotificationNames {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(BaseTableViewController.keyboardWillAdjustFrame(_:)),
                                                   name: notificationName,
                                                   object: nil)
        }
    }
    
    func deregisterForKeyboardNotifications() {
        for notificationName in BaseTableViewController.keyboardNotificationNames {
            NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
        }
    }
    
    // MARK: Private Methods
    
    @objc fileprivate func keyboardWillAdjustFrame(_ sender: Notification) {
        guard let userInfo = (sender as NSNotification).userInfo else {
            return
        }
        
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = UIScreen.main.bounds.height - keyboardFrame.minY
        let duration = TimeInterval(userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        
        var animationCurve: UIViewAnimationOptions = .curveLinear
        if let animationCurveInt = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue {
            animationCurve = UIViewAnimationOptions(rawValue: animationCurveInt<<16)
        }
        
        keyboardWillUpdateVisibleHeight(keyboardHeight, withDuration: duration, animationCurve: animationCurve)
    }
    
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat,
                                         withDuration duration: TimeInterval,
                                         animationCurve: UIViewAnimationOptions) {
        var tvContentInset = tableView.contentInset
        tvContentInset.bottom = height
        tableView.contentInset = tvContentInset
    }
}

// MARK: - UITableViewCell Helpers

extension BaseTableViewController {
    
    func buttonCell(title: String?,
                    loading: Bool = false,
                    for indexPath: IndexPath,
                    sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? buttonSizingCell
            : tableView.dequeueReusableCell(withIdentifier: ButtonCell.reuseId, for: indexPath) as? ButtonCell
        
        cell?.title = title
        cell?.loading = loading
        
        return cell ?? UITableViewCell()
    }
    
    func imageNameCell(name: String,
                       imageName: String,
                       for indexPath: IndexPath,
                       sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? imageNameSizingCell
            : tableView.dequeueReusableCell(withIdentifier: ImageNameCell.reuseId, for: indexPath) as? ImageNameCell
        
        cell?.appSettings = AppSettings.shared
        cell?.selectionStyle = .default
        cell?.name = name
        cell?.imageName = imageName
        
        return cell ?? UITableViewCell()
    }
    
    func imageViewCarouselCell(imageNames: [String]?,
                               selectedImageName: String? = nil,
                               onSelection: ((_ imageName: String) -> Void)? = nil,
                               for indexPath: IndexPath,
                               sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? imageViewCarouselSizingCell
            : tableView.dequeueReusableCell(withIdentifier: ImageViewCarouselCell.reuseId, for: indexPath) as? ImageViewCarouselCell
        
        cell?.imageNames = imageNames
        cell?.selectedImageName = selectedImageName
        cell?.onSelection = onSelection
        
        return cell ?? UITableViewCell()
    }
    
    func labelIconCell(title: String?,
                       imageName: String?,
                       for indexPath: IndexPath,
                       sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? labelIconSizingCell
            : tableView.dequeueReusableCell(withIdentifier: LabelIconCell.reuseId, for: indexPath) as? LabelIconCell
        
        cell?.appSettings = AppSettings.shared
        cell?.selectionStyle = .default
        cell?.title = title
        if let imageName = imageName {
            cell?.iconImage = UIImage(named: imageName)
        } else {
            cell?.iconImage = nil
        }
        
        return cell ?? UITableViewCell()
    }
    
    func textCell(forIndexPath indexPath: IndexPath,
                  title: String?,
                  detailText: String? = nil,
                  accessoryType: UITableViewCellAccessoryType = .none) -> UITableViewCell {
        let textCellReuseId = "TextCellReuseId"
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellReuseId) ?? UITableViewCell(style: .value1, reuseIdentifier: textCellReuseId)
        
        cell.textLabel?.text = title
        cell.textLabel?.font = AppSettings.shared.branding.fontFamily.bold.withSize(16)
        cell.textLabel?.textColor = UIColor.darkGray
        
        cell.detailTextLabel?.text = detailText
        cell.detailTextLabel?.font = AppSettings.shared.branding.fontFamily.regular.withSize(16)
        cell.detailTextLabel?.textColor = UIColor.gray
        
        cell.accessoryType = accessoryType
        
        return cell
    }
    
    func textInputCell(text: String? = nil,
                       placeholder: String? = nil,
                       labelText: String? = nil,
                       autocapitalizationType: UITextAutocapitalizationType = .none,
                       isSecureTextEntry: Bool = false,
                       onTextChange: ((_ text: String) -> Void)? = nil,
                       onReturnKey: ((_ text: String) -> Void)? = nil,
                       for indexPath: IndexPath,
                       sizingOnly: Bool) -> TextInputCell {
        
        let cell = sizingOnly
            ? textInputSizingCell
            : tableView.dequeueReusableCell(withIdentifier: TextInputCell.reuseId, for: indexPath) as? TextInputCell
        
        cell?.appSettings = AppSettings.shared
        cell?.currentText = text ?? ""
        cell?.placeholderText = placeholder
        cell?.labelText = labelText
        cell?.textField.autocorrectionType = .no
        cell?.textField.autocapitalizationType = autocapitalizationType
        cell?.textField.returnKeyType = .done
        cell?.textField.isSecureTextEntry = isSecureTextEntry
        cell?.dismissKeyboardOnReturn = true
        cell?.onTextChange = onTextChange
        cell?.onReturnKey = onReturnKey
        
        return cell ?? TextInputCell()
    }
    
    func titleCheckMarkCell(title: String?,
                            isChecked: Bool,
                            loading: Bool = false,
                            for indexPath: IndexPath,
                            sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? titleCheckmarkSizingCell
            : tableView.dequeueReusableCell(withIdentifier: TitleCheckmarkCell.reuseId, for: indexPath) as? TitleCheckmarkCell
        
        cell?.appSettings = AppSettings.shared
        cell?.title = title
        cell?.isChecked = isChecked
        cell?.loading = loading
        
        return cell ?? UITableViewCell()
    }
    
    func titleDetailValueCell(title: String? = nil,
                              detail: String? = nil,
                              value: String? = nil,
                              for indexPath: IndexPath,
                              sizingOnly: Bool) -> UITableViewCell {
        let cell = sizingOnly
            ? titleDetailValueSizingCell
            : tableView.dequeueReusableCell(withIdentifier: TitleDetailValueCell.reuseId, for: indexPath) as? TitleDetailValueCell
        
        cell?.appSettings = AppSettings.shared
        cell?.selectionStyle = .default
        cell?.update(titleText: title, detailText: detail, valueText: value)
        
        return cell ?? UITableViewCell()
    }
}

// MARK: - UITableViewDataSource

extension BaseTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCellForIndexPath(indexPath, forSizing: false)
    }
    
    // MARK: OVERRIDE THIS METHOD
    
    func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        fatalError("Subclass must override tableView:cellForRowAt:")
    }
}

// MARK: - UITableViewDelegate

extension BaseTableViewController: UITableViewDelegate {
    
    // MARK: Internal
    
    func titleForSection(_ section: Int) -> String? {
        return nil
    }
    
    // MARK: Header
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let title = titleForSection(section) {
            let headerView = TableHeaderView()
            headerView.title = title
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let title = titleForSection(section) {
            headerSizingView.title = title
            return headerSizingView.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height
        }
        return 0.00001
    }
    
    // MARK: Footers
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == numberOfSections(in: tableView) - 1 {
            return 64.0
        }
        return 0.00001
    }
    
    // MARK: Rows
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = getCellForIndexPath(indexPath, forSizing: true)
        return ceil(cell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // No-op
    }
}
