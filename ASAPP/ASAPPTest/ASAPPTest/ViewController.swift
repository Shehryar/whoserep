//
//  ViewController.swift
//  ASAPPTest
//
//  Created by Vicky Sehrawat on 6/14/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

class ViewController: UIViewController {

    var asapp: ASAPP!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        if asapp == nil {
            asapp = ASAPP(company:"vs-dev", userToken: "vs-cct-c5", isCustomer: true)
//            asapp.targetCustomerToken("customerdummytest")
        }
        let vc = asapp.viewControllerForChat()
        self.presentViewController(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
