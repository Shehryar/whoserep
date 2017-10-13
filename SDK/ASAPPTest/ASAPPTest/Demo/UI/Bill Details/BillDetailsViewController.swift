//
//  BillDetailsViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class BillDetailsViewController: BaseTableViewController {
    
    // MARK: Cells
    
    let labelIconCellReuseId = "LabelIconCellReuseId"
    let titleDetailValueCellReuseId = "TitleDetailValueCellReuseId"
    
    let labelIconSizingCell = LabelIconCell()
    let titleDetailValueSizingCell = TitleDetailValueCell()
    
    // MARK: Data
    
    let billDetails = BillDetails()
    
    // MARK: Enums
    
    enum Section: Int {
        case summary
        case payment
        case lineItems
        case count
    }
    
    enum PaymentRow: Int {
        case makePayment
        case schedulePayment
        case count
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        title = "Bill Details"
        
        tableView.register(LabelIconCell.self, forCellReuseIdentifier: labelIconCellReuseId)
        tableView.register(TitleDetailValueCell.self, forCellReuseIdentifier: titleDetailValueCellReuseId)
    }
}

// MARK: - UITableViewDataSource

extension BillDetailsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.summary.rawValue: return 1
        case Section.payment.rawValue: return PaymentRow.count.rawValue
        case Section.lineItems.rawValue: return billDetails.lineItems.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {

        case Section.summary.rawValue, Section.lineItems.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: titleDetailValueCellReuseId, for: indexPath) as? TitleDetailValueCell
            styleLineItemCell(cell, for: indexPath)
            return cell ?? UITableViewCell()
            
        case Section.payment.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: labelIconCellReuseId, for: indexPath) as? LabelIconCell
            stylePaymentCell(cell, forRow: indexPath.row)
            return cell ?? UITableViewCell()
            
        default:
            // No-op
            break
        }
        
        return UITableViewCell()
    }
    
    // MARK: Internal
    
    func stylePaymentCell(_ cell: LabelIconCell?, forRow row: Int) {
        guard let cell = cell else { return }
        cell.appSettings = AppSettings.shared
        
        switch row {
        case PaymentRow.makePayment.rawValue:
            cell.title = "Make Payment"
            cell.iconImage = UIImage(named: "icon-coin")
            break
            
        case PaymentRow.schedulePayment.rawValue:
            cell.title = "Schedule Payment"
            cell.iconImage = UIImage(named: "icon-calendar")
            break
            
        default:
            // No-op
            break
        }
    }
    
    func styleLineItemCell(_ cell: TitleDetailValueCell?, for indexPath: IndexPath) {
        guard let cell = cell else { return }
        cell.appSettings = AppSettings.shared
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case Section.summary.rawValue:
            
            cell.titleLabel.font = AppSettings.shared.branding.fontFamily.regular.withSize(18)
            cell.valueLabel.font = AppSettings.shared.branding.fontFamily.light.withSize(22)
            cell.detailLabel.font = AppSettings.shared.branding.fontFamily.light.withSize(16)
            cell.update(titleText: "Current Balance",
                        detailText: billDetails.dueDateString,
                        valueText: billDetails.total)
            break
            
        case Section.lineItems.rawValue:
            cell.titleLabel.font = AppSettings.shared.branding.fontFamily.regular.withSize(16)
            cell.valueLabel.font = AppSettings.shared.branding.fontFamily.light.withSize(16)
            cell.detailLabel.font = AppSettings.shared.branding.fontFamily.light.withSize(14)
            let lineItem = billDetails.lineItems[indexPath.row]
            cell.update(titleText: lineItem.name,
                        detailText: lineItem.date,
                        valueText: lineItem.amount)
            break
            
        default: break
        }
    }
    
}

// MARK: - UITableViewDelegate

extension BillDetailsViewController {
    
    override func titleForSection(_ section: Int) -> String? {
        switch section {
        case Section.summary.rawValue: return "Summary"
        case Section.payment.rawValue: return "Payment Options"
        case Section.lineItems.rawValue: return "Line Items"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sizer = CGSize(width: tableView.bounds.width, height: 0)
        
        switch indexPath.section {
        case Section.summary.rawValue, Section.lineItems.rawValue:
            styleLineItemCell(titleDetailValueSizingCell, for: indexPath)
            return titleDetailValueSizingCell.sizeThatFits(sizer).height
            
        case Section.payment.rawValue:
            stylePaymentCell(labelIconSizingCell, forRow: indexPath.row)
            return labelIconSizingCell.sizeThatFits(sizer).height
        
        default:
            return 50.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
