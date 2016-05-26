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
        self.setupTabBar()
    }
    
    func setupTabBar() {
        navBar = ASAPPNavBar(controllerHandler: { (oldController, newController) in
            self.setupChildController(oldController, newController: newController)
        })
        self.view.addSubview(navBar)
        navBar.snp_makeConstraints { (make) in
            make.width.equalTo(UIScreen.mainScreen().bounds.size.width)
            make.height.equalTo(70)
            make.top.equalTo(self.view.snp_topMargin).offset(0)
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

