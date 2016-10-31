//
//  BillDetailsViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class BillDetailsViewController: BaseTableViewController {

    let billOverview = BillOverview(balance: "$126.22",
                                    billingPeriod: "10/15-2016 - 11/14/2016")
    
    let billingPeriod = "10/15/2016 - 11/14/2016"
    
    let lineItemReuseId = "LineItemReuseId"
    
    let lineItemSizingCell = BillDetailsLineItemCell()
    
    let headerSizingView = BillDetailsHeaderView()
    
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
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        title = "Bill Details"
        
        tableView.delegate = self
        tableView.register(BillDetailsLineItemCell.self, forCellReuseIdentifier: lineItemReuseId)
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        tableView.backgroundColor = UIColor.white
    }
}

// MARK:- UITableViewDataSource

extension BillDetailsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lineItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: lineItemReuseId, for: indexPath) as! BillDetailsLineItemCell
        cell.update(lineItem: lineItems[indexPath.row])
        
        return cell
    }
}

// MARK:- UITableViewDelegate

extension BillDetailsViewController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = BillDetailsHeaderView()
        headerView.update(billOverview: billOverview)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerSizingView.update(billOverview: billOverview)
        let height = headerSizingView.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height
        return ceil(height)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        lineItemSizingCell.update(lineItem: lineItems[indexPath.row])
        let height = lineItemSizingCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: 0)).height
        
        return ceil(height)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

