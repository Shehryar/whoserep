//
//  ColorPickerViewController.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 12/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol ColorPickerViewControllerDelegate: class {
    func colorPickerViewController(_ viewController: ColorPickerViewController, didFinishPickingColor color: UIColor?)
}

class ColorPickerViewController: BaseTableViewController {
    enum Section: Int, CountableEnum {
        case color
    }
    
    enum ColorRow: Int, CountableEnum {
        case preview
        case input
    }
    
    weak var delegate: ColorPickerViewControllerDelegate?
    
    var color: UIColor? {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
}

extension ColorPickerViewController {    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            delegate?.colorPickerViewController(self, didFinishPickingColor: color)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .some(.color):
            return ColorRow.count
        case .none:
            return 0
        }
    }
    
    override func getCellForIndexPath(_ indexPath: IndexPath, forSizing: Bool) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .some(.color):
            switch ColorRow(rawValue: indexPath.row) {
            case .some(.preview):
                let cell = UITableViewCell()
                cell.backgroundColor = color
                cell.selectionStyle = .none
                cell.separatorInset = .zero
                return cell
            case .some(.input):
                let cell = textInputCell(text: color?.hexString, labelText: "Hex", autocapitalizationType: .none, onTextChange: { [weak self] string in
                    if string.count == 6 {
                        self?.color = UIColor(hexString: string)
                    }
                }, for: indexPath, sizingOnly: forSizing)
                cell.textField.delegate = self
                cell.becomeFirstResponder()
                return cell
            case .none:
                return UITableViewCell()
            }
        case .none:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .some(.color):
            switch ColorRow(rawValue: indexPath.row) {
            case .some(.preview):
                return
            case .some(.input):
                tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
                tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            case .none:
                return
            }
        case .none:
            return
        }
    }
}

extension ColorPickerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        let length = text.count + string.count - range.length
        return length <= 6
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text,
              text.count == 6,
              let color = UIColor(hexString: text) else {
            return false
        }
        
        self.color = color
        navigationController?.popViewController(animated: true)
        return true
    }
}
