//
//  ContainerViewController.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 8/28/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    private var nav: UINavigationController!
    
    init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        
        nav = NavigationController(rootViewController: rootViewController)
        addChild(nav)
    }
    
    override func loadView() {
        let view = UIView()
        
        view.addSubview(nav.view)
        nav.view.frame = view.bounds
        
        self.view = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(false, animated: animated)
            nav.viewControllers = []
            nav = nil
        }
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return nav.topViewController!.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return nav.topViewController!.prefersStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return nav.topViewController!.preferredStatusBarUpdateAnimation
    }
    
    // Orientation
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return nav.preferredInterfaceOrientationForPresentation
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return nav.supportedInterfaceOrientations
    }
    
    override var shouldAutorotate: Bool {
        return nav.shouldAutorotate
    }
}
