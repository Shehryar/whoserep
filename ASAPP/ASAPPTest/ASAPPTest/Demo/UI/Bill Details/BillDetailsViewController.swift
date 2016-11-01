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
    
    let billSummaryCellReuseId = "BillSummaryCellReuseId"
    let textIconCellReuseId = "TextIconCellReuseId"
    let titleDetailValueCellReuseId = "TitleDetailValueCellReuseId"
    
    let summarySizingCell = BillSummaryCell()
    let textIconSizingCell = HomeTextIconCell()
    let titleDetailValueSizingCell = TitleDetailValueCell()
    
    // MARK: Data
    
    let billingPeriod = "10/15/2016 - 11/14/2016"
    
    let lineItems = [
        LineItem(name: "Movie: Avengers 2",
                 date: "10/11/2016",
                 amount: "$5.99"),
        LineItem(name: "Internet: Misc Charge",
                 date: "10/10/2016",
                 amount: "$5.99"),
        LineItem(name: "HBO: Charge",
                 date: "10/10/2016",
                 amount: "$5.99"),
        LineItem(name: "Internet: Misc Charge",
                 date: "10/5/2016",
                 amount: "$5.99"),
        LineItem(name: "Internet: Misc Charge",
                 date: "10/1/2016",
                 amount: "$5.99"),
        ]
    
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
    
    required init(appSettings: AppSettings) {
        super.init(appSettings: appSettings)
        
        title = "Bill Details"
        
        tableView.register(BillSummaryCell.self, forCellReuseIdentifier: billSummaryCellReuseId)
        tableView.register(HomeTextIconCell.self, forCellReuseIdentifier: textIconCellReuseId)
        tableView.register(TitleDetailValueCell.self, forCellReuseIdentifier: titleDetailValueCellReuseId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- UITableViewDataSource

extension BillDetailsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.summary.rawValue: return 1
        case Section.payment.rawValue: return PaymentRow.count.rawValue
        case Section.lineItems.rawValue: return lineItems.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case Section.summary.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: billSummaryCellReuseId, for: indexPath) as? TableViewCell
            cell?.appSettings = appSettings
            return cell ?? UITableViewCell()
            
        case Section.payment.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: textIconCellReuseId, for: indexPath) as? HomeTextIconCell
            stylePaymentCell(cell, forRow: indexPath.row)
            return cell ?? UITableViewCell()
            
        case Section.lineItems.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: titleDetailValueCellReuseId, for: indexPath) as? TitleDetailValueCell
            styleLineItemCell(cell, forRow: indexPath.row)
            return cell ?? UITableViewCell()
            
        default:
            // No-op
            break
        }
        
        
        return UITableViewCell()
    }
    
    // MARK: Internal
    
    func stylePaymentCell(_ cell: HomeTextIconCell?, forRow row: Int) {
        guard let cell = cell else { return }
        cell.appSettings = appSettings
        
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
    
    func styleLineItemCell(_ cell: TitleDetailValueCell?, forRow row: Int) {
        guard let cell = cell else { return }
        cell.appSettings = appSettings
        
        let lineItem = lineItems[row]
        cell.update(titleText: lineItem.name,
                    detailText: lineItem.date,
                    valueText: lineItem.amount)
        
    }
    
}

// MARK:- UITableViewDelegate

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
        case Section.summary.rawValue:
            summarySizingCell.appSettings = appSettings
            return summarySizingCell.sizeThatFits(sizer).height
            
        case Section.payment.rawValue:
            stylePaymentCell(textIconSizingCell, forRow: indexPath.row)
            return textIconSizingCell.sizeThatFits(sizer).height
            
        case Section.lineItems.rawValue:
            styleLineItemCell(titleDetailValueSizingCell, forRow: indexPath.row)
            return titleDetailValueSizingCell.sizeThatFits(sizer).height
            
        default:
            return 50.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
