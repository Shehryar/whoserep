//
//  AppDelegate.swift
//  ASAPPTest
//
//  Created by Vicky Sehrawat on 6/14/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP
import Fabric
import UserNotifications
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var homeController: HomeViewController!
    
    // MARK: - Application Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Crashlytics.sharedInstance().debugMode = true
        Fabric.with([Crashlytics.self, Answers.self])
        
        ASAPP.debugLogLevel = .debug
        
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.isTranslucent = false
        navBarAppearance.backgroundColor = UIColor.white

        ASAPP.loadFonts()
        homeController = HomeViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = NavigationController(rootViewController: homeController)
        window!.makeKeyAndVisible()
        
        setupNotifications()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        UserDefaults.standard.synchronize()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        UserDefaults.standard.synchronize()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Notifications

extension AppDelegate {
    
    func setupNotifications() {
        let settings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        // https://developer.apple.com/reference/usernotifications/unusernotificationcenterdelegate
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    // MARK: Notifications Registration
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let bundleId = Bundle.main.bundleIdentifier ?? "unknown"
        
        demoLog("application:didRegisterForRemoteNotificationsWithDeviceToken:\n  bundleId: \(bundleId))\n  device token: \(token)")
        
        Answers.logCustomEvent(withName: "Registered for Push Notifications", customAttributes: [
            "deviceToken": token,
            "bundleId": bundleId
            ])
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        demoLog("application: didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }
    
    // MARK: Notification Received
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        demoLog("application:didReceiveRemoteNotification\n \(userInfo))")
        
        if ASAPP.canHandleNotification(with: userInfo) {
            homeController.showChat(fromNotificationWith: userInfo)
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    func application(_ application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     forRemoteNotification userInfo: [AnyHashable: Any],
                     completionHandler: @escaping () -> Void) {
        demoLog("application:handleActionWithIdentifier:forRemoteNotification:completionHandler\n \(userInfo))")
    }
    
    func application(_ application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     forRemoteNotification userInfo: [AnyHashable: Any],
                     withResponseInfo responseInfo: [AnyHashable: Any],
                     completionHandler: @escaping () -> Void) {
        demoLog("application:handleActionWithIdentifier:forRemoteNotification:withResponseInfo:completionHandler\n \(userInfo))")
    }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
        
        demoLog("userNotificationCenter:willPresent:withCompletionHandler:")
    }
}
