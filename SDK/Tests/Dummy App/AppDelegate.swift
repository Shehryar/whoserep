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
    TextInputMaxLength.self,
    FormValidation.self,
    FormWithScale.self,
    FormWithRadio.self,
    ImageLayout.self,
    Dropdown.self
]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test")
        ASAPP.initialize(with: config)
        ASAPP.user = ASAPPUser(userIdentifier: "test", requestContextProvider: { _ in
            return [:]
        })
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let classesByIdentifier = testCaseViewControllers.reduce(into: [String: TestCaseViewController.Type]()) {
            $0[$1.testCaseIdentifier] = $1
        }
        
        let testCaseName = CommandLine.arguments[1]
        var viewController: UIViewController
        let messagePrefix = "message:"
        let formPrefix = "form:"
        
        if testCaseName.hasPrefix(messagePrefix) {
            let fileName = testCaseName.dropFirst(messagePrefix.count)
            let singleMessage = SingleMessageViewController()
            viewController = singleMessage
            singleMessage.showMessage(fileName: String(fileName))
        } else if testCaseName.hasPrefix(formPrefix) {
            let fileName = testCaseName.dropFirst(formPrefix.count)
            let controller = ComponentViewContainerController()
            viewController = controller
            controller.showContainer(fileName: String(fileName))
        } else if let testCaseViewControllerClass = classesByIdentifier[testCaseName] {
            viewController = testCaseViewControllerClass.init()
        } else {
            viewController = UIViewController()
        }
        
        window!.rootViewController = viewController
        window!.makeKeyAndVisible()
        
        return true
    }
}
