//
//  AppDelegate.swift
//  Tests
//
//  Created by Hans Hyttinen on 10/18/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import UIKit
import ASAPP

typealias TestCaseViewController = UIViewController & IdentifiableTestCase

let testCaseViewControllers: [TestCaseViewController.Type] = [
    TextAreaMaxLength.self,
    TextInputMaxLength.self
]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test")
        ASAPP.initialize(with: config)
        ASAPP.user = ASAPPUser(userIdentifier: "test", requestContextProvider: {
            return [:]
        }, userLoginHandler: { _ in })
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let classesByIdentifier = testCaseViewControllers.reduce(into: [String: TestCaseViewController.Type]()) {
            $0[$1.testCaseIdentifier] = $1
        }
        
        let testCaseName = CommandLine.arguments[1]
        var viewController: UIViewController
        if let testCaseViewControllerClass = classesByIdentifier[testCaseName] {
            viewController = testCaseViewControllerClass.init()
        } else {
            viewController = UIViewController()
        }
        
        window!.rootViewController = viewController
        window!.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
