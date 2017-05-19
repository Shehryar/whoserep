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
        self.statusBarStyle = self.appSettings.branding.colors.statusBarStyle
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
        
        statusBarStyle = appSettings.branding.colors.statusBarStyle
        
        view.backgroundColor = appSettings.branding.colors.backgroundColor
        
        styleNavigationBarWithAppSettings(navBar: navigationController?.navigationBar)
    }
    
    func styleNavigationBarWithAppSettings(navBar: UINavigationBar?) {
        guard let navBar = navBar else { return }
        
        navBar.isTranslucent = true
        navBar.setBackgroundImage(nil, for: .default)
        navBar.backgroundColor = nil
        if appSettings.branding.colors.navBarColor == UIColor.black {
            navBar.barTintColor = nil
            navBar.barStyle = .black
        } else if appSettings.branding.colors.navBarColor == UIColor.white {
            navBar.barTintColor = nil
            navBar.barStyle = .default
        } else {
            navBar.barTintColor = appSettings.branding.colors.navBarColor
        }
        
        
        navBar.tintColor = appSettings.branding.colors.navBarTintColor
        navBar.titleTextAttributes = [
            NSForegroundColorAttributeName : appSettings.branding.colors.navBarTitleColor,
            NSFontAttributeName : appSettings.branding.fonts.lightFont.withSize(19)
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : appSettings.branding.fonts.regularFont.withSize(16),
            //NSForegroundColorAttributeName : appSettings.navBarTintColor
            ],
                                                            for: .normal)

    }
}
