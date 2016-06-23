//
//  JourneyTableViewController.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 6/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class JourneyTableViewController: UITableViewController {
    
    var dataSource: TimelineDataSource!
    var journeys : [TimelineModel.CCJourney] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.03)
        self.tableView.allowsSelection = false
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.registerClass(JourneyTableViewCell.self, forCellReuseIdentifier: "customJourneyCell")
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        if dataSource != nil {
            journeys = dataSource.timelineJourneys()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeys.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("customJourneyCell", forIndexPath: indexPath) as! JourneyTableViewCell

        cell.updateJourney(journeys[indexPath.row])

        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
