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
    
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    // MARK:- Initialization
    
    func commonInit() {
        statusBarStyle = AppSettings.shared.branding.colors.statusBarStyle
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
        
    // MARK:- View 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadViewForUpdatedSettings()
    }
    
    func canNavigateBack() -> Bool {
        if let navigationController = navigationController,
            let index = navigationController.viewControllers.index(of: self),
            index > 0 {
            return true
        }
        return false
    }
    
}

extension BaseViewController: AppSettingsViewController {
    
    func reloadViewForUpdatedSettings() {
        
        statusBarStyle = AppSettings.shared.branding.colors.statusBarStyle
        
        view.backgroundColor = AppSettings.shared.branding.colors.backgroundColor
        
        styleNavigationBarWithAppSettings(navBar: navigationController?.navigationBar)
    }
    
    func styleNavigationBarWithAppSettings(navBar: UINavigationBar?) {
        guard let navBar = navBar else { return }
        
        let branding = AppSettings.shared.branding
        
        navBar.isTranslucent = true
        navBar.setBackgroundImage(nil, for: .default)
        navBar.backgroundColor = nil
        if branding.colors.navBarColor == UIColor.black {
            navBar.barTintColor = nil
            navBar.barStyle = .black
        } else if AppSettings.shared.branding.colors.navBarColor == UIColor.white {
            navBar.barTintColor = nil
            navBar.barStyle = .default
        } else {
            navBar.barTintColor = AppSettings.shared.branding.colors.navBarColor
        }
        
        
        navBar.tintColor = AppSettings.shared.branding.colors.navBarTintColor
        navBar.titleTextAttributes = [
            NSForegroundColorAttributeName : AppSettings.shared.branding.colors.navBarTitleColor,
            NSFontAttributeName : AppSettings.shared.branding.fonts.lightFont.withSize(19)
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : AppSettings.shared.branding.fonts.regularFont.withSize(16),
            //NSForegroundColorAttributeName : appSettings.navBarTintColor
            ],
                                                            for: .normal)
    }
}
