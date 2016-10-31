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

    var appSettings: AppSettings = AppSettings.settingsFor(.asapp) {
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
    }
}
