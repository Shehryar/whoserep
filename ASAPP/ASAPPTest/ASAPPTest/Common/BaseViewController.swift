//
//  BaseViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol AppSettingsViewController {
    func reloadViewForUpdatedSettings()
}

class BaseViewController: UIViewController {

    var appSettings: AppSettings {
        didSet {
            reloadViewForUpdatedSettings()
        }
    }
    
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    // MARK:- Initialization
    
    required init(appSettings: AppSettings) {
        self.appSettings = appSettings
        self.statusBarStyle = self.appSettings.statusBarStyle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- View 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadViewForUpdatedSettings()
    }
}

extension BaseViewController: AppSettingsViewController {
    
    func reloadViewForUpdatedSettings() {
        
        statusBarStyle = appSettings.statusBarStyle
        
        view.backgroundColor = appSettings.backgroundColor
        
        styleNavigationBarWithAppSettings(navBar: navigationController?.navigationBar)
    }
    
    func styleNavigationBarWithAppSettings(navBar: UINavigationBar?) {
        guard let navBar = navBar else { return }
        
        navBar.isTranslucent = true
        navBar.setBackgroundImage(nil, for: .default)
        navBar.backgroundColor = nil
        if appSettings.navBarColor == UIColor.black {
            navBar.barTintColor = nil
            navBar.barStyle = .black
        } else if appSettings.navBarColor == UIColor.white {
            navBar.barTintColor = nil
            navBar.barStyle = .default
        } else {
            navBar.barTintColor = appSettings.navBarColor
        }
        
        
        navBar.tintColor = appSettings.navBarTintColor
        navBar.titleTextAttributes = [
            NSForegroundColorAttributeName : appSettings.navBarTitleColor,
            NSFontAttributeName : appSettings.lightFont.withSize(19)
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : appSettings.regularFont.withSize(16),
            //NSForegroundColorAttributeName : appSettings.navBarTintColor
            ],
                                                            for: .normal)

    }
}
