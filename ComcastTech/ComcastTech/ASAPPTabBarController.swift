//
//  ViewController.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 3/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ASAPPTabBarController: UIViewController {

    var navBar: ASAPPNavBar!
    var container: UIContentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.whiteColor()
        self.renderTabBar()
    }
    
    func renderTabBar() {
        navBar = ASAPPNavBar(style: .Primary, controllerHandler: { (oldController, newController) in
            self.setupChildController(oldController, newController: newController)
        })
        
        navBar.addButton(.Image, value: "icon_chat-white.png", targetController: ChatViewController(), isDefault: false)
        navBar.addButton(.Text, value: "CHECK", targetController: ASAPPCheckController(), isDefault: true)
        navBar.addButton(.Text, value: "TIMELINE", targetController: TimelineTabViewController(), isDefault: false)
        navBar.addButton(.Image, value: "icon_logout-white.png", targetController: ChatViewController(), isDefault: false)
        
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
        viewController.view.frame = CGRectMake(0, 70, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - 70)
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
            make.height.equalTo(70)
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


}

