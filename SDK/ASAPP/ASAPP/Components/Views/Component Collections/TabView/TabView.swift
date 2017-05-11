//
//  TabView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/10/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TabView: BaseComponentView {

    let tabBar = TabViewTabBar()
    
    let pageContainerView = UIView()
    
    // MARK: Properties

    fileprivate(set) var pageViews: [ComponentView]? {
        didSet {
            // Remove old views
            if let oldPageViews = pageViews {
                for pageView in oldPageViews {
                    pageView.view.removeFromSuperview()
                }
            }
            
            // Add new views
            if let pageViews = pageViews {
                for pageView in pageViews {
                    pageContainerView.addSubview(pageView.view)
                }
            }
            
            setNeedsLayout()
        }
    }
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            guard let tabViewItem = tabViewItem else {
                tabBar.pages = nil
                self.pageViews = nil
                return
            }
            
            // Update Tab Bar
            tabBar.pages = tabViewItem.pages
            
            // Update Page Views
            var pageViews = [ComponentView]()
            for pageItem in tabViewItem.pages {
                if let pageView = pageItem.root.createView() {
                    pageViews.append(pageView)
                }
            }
            self.pageViews = pageViews
           
            updateHandlersForNestedComponentViews()
        }
    }
    
    override var nestedComponentViews: [ComponentView]? {
        return pageViews
    }
    
    var tabViewItem: TabViewItem? {
        return component as? TabViewItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        backgroundColor = ASAPP.styles.colors.backgroundPrimary
        
        pageContainerView.clipsToBounds = true
        pageContainerView.backgroundColor = backgroundColor
        addSubview(pageContainerView)
        
        addSubview(tabBar)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let tabBarHeight = ceil(tabBar.sizeThatFits(bounds.size).height)
        tabBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: tabBarHeight)
        
        let pageHeight = bounds.height - tabBarHeight
        pageContainerView.frame = CGRect(x: 0, y: tabBarHeight,
                                         width: bounds.width, height: pageHeight)
        
        if let pageViews = pageViews {
            for pageView in pageViews {
                pageView.view.frame = pageContainerView.bounds
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let pageViews = pageViews else {
            return .zero
        }
        
        let tabBarSize = tabBar.sizeThatFits(size)
        let maxPageSize = CGSize(width: size.width,
                                 height: max(0, size.height - tabBarSize.height))
        
        var maxCalculatedPageSize = CGSize.zero
        for pageView in pageViews {
            let pageSize = pageView.view.sizeThatFits(maxPageSize)
            maxCalculatedPageSize.width = max(pageSize.width,
                                              maxCalculatedPageSize.width)
            maxCalculatedPageSize.height = max(pageSize.height,
                                               maxCalculatedPageSize.height)
        }
        
        let fittedWidth = ceil(max(tabBarSize.width, maxCalculatedPageSize.width))
        let fittedHeight = ceil(maxCalculatedPageSize.height)
        
        return CGSize(width: fittedWidth, height: fittedHeight)
    }
}
