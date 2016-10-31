//
//  AppDelegate.swift
//  ASAPPTest
//
//  Created by Vicky Sehrawat on 6/14/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var homeController: HomeViewController!
    
    // MARK:- Application Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Settings to mimc Comcast
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.isTranslucent = false
        navBarAppearance.backgroundColor = UIColor.white
        
        updateDemoSettings()
        
        let appSettings = defaultAppSettings()
        let canChangeCompany = canChangeCompanies()
        homeController = HomeViewController(appSettings: appSettings, canChangeCompany: canChangeCompany)
        
        Fabric.with([Crashlytics.self])
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = NavigationController(rootViewController: homeController)
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK:- Setup

extension AppDelegate {
    
    func defaultAppSettings() -> AppSettings {
        if let companyString = Bundle.main.infoDictionary?["default-demo-company"] as? String {
            if let company = Company(rawValue: companyString) {
                return AppSettings.settingsFor(company)
            }
        }
        return AppSettings.settingsFor(.asapp)
    }
    
    func canChangeCompanies() -> Bool {
        return Bundle.main.infoDictionary?["company-changing-disabled"] as? String == "NO"
    }
    
    func updateDemoSettings() {
        // Demo Content
        if Bundle.main.infoDictionary?["demo-content-enabled"] as? String == "YES" {
            DemoSettings.setDemoContentEnabled(true)
        } else {
            DemoSettings.setDemoContentEnabled(false)
        }
        
        // Demo Live Chat
        if Bundle.main.infoDictionary?["demo-live-chat"] as? String == "YES" {
            DemoSettings.setDemoLiveChat(true)
            DemoSettings.setUseDemoPhoneUser(true)
            DemoSettings.setCurrentEnvironment(environment: .staging)
        } else {
            DemoSettings.setDemoLiveChat(false)
            DemoSettings.setUseDemoPhoneUser(false)
        }
    }
}
