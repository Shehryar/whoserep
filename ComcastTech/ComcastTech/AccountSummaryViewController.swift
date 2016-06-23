//
//  AccountSummaryViewController.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 6/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class AccountSummaryViewController: UITableViewController {

    var dataSource: TimelineDataSource!
    var account: TimelineModel.CCAccount!
    var activities : [TimelineModel.CCActivity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.03)
        self.tableView.allowsSelection = false
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerClass(AccountTableViewCell.self, forCellReuseIdentifier: "customAccountCell")
        self.tableView.registerClass(ActivityTableViewCell.self, forCellReuseIdentifier: "customActivityCell")
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        if dataSource != nil {
            account = dataSource.timelineAccount()
            activities = dataSource.timelineActivities()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return activities.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("customAccountCell", forIndexPath: indexPath) as! AccountTableViewCell
            cell.updateAccount(account)
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("customActivityCell", forIndexPath: indexPath) as! ActivityTableViewCell
            cell.updateActivity(activities[indexPath.row])
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        } else {
            return 100
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        
        if section == 1 {
            let headerLabel = UILabel()
            headerLabel.font = UIFont(name: "Lato-Regular", size: 11)
            headerLabel.text = "RECENT ACTIVITIES"
            headerLabel.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
            headerView.addSubview(headerLabel)
            
            headerLabel.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(headerView).offset(20)
                make.leading.equalTo(headerView).offset(30)
                make.trailing.equalTo(headerView).offset(-30)
                make.bottom.equalTo(headerView).offset(-10)
            })
        }
        
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 45
        }
        
        return 15
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
