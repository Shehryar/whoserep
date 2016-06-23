//
//  TimelineTabViewController.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 6/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol TimelineDataSource {
    func timelineAccount() -> TimelineModel.CCAccount
    func timelineActivities() -> [TimelineModel.CCActivity]
    func timelineJourneys() -> [TimelineModel.CCJourney]
}

class TimelineTabViewController: UIViewController {

    var navBar: ASAPPNavBar!
    
    var timelineModel: TimelineModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        timelineModel = TimelineModel()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.renderTabBar()
    }
    
    func renderTabBar() {
        navBar = ASAPPNavBar(style: .Secondary, controllerHandler: { (oldController, newController) in
            self.setupChildController(oldController, newController: newController)
        })
        
        let accountVC = AccountSummaryViewController()
        accountVC.dataSource = timelineModel
        let journeyVC = JourneyTableViewController()
        journeyVC.dataSource = timelineModel
        
        navBar.addButton(.Text, value: "ACCOUNT SUMMARY", targetController: accountVC, isDefault: true)
        navBar.addButton(.Text, value: "OPEN JOURNEYS", targetController: journeyVC, isDefault: false)
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(navBar)
    }
    
    func setupChildController(oldController: UIViewController?, newController: UIViewController) {
        if oldController != nil {
            removeChildController(oldController!)
        }
        addChildController(newController)
    }
    
    func addChildController(viewController: UIViewController) {
        self.addChildViewController(viewController)
        viewController.view.frame = CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height - 50)
        self.view.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
    }
    
    func removeChildController(viewController: UIViewController) {
        viewController.willMoveToParentViewController(nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func updateViewConstraints() {
        navBar.snp_makeConstraints { (make) in
            make.height.equalTo(50)
            make.top.equalTo(self.view.snp_topMargin).offset(0)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
        }
        
        super.updateViewConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
