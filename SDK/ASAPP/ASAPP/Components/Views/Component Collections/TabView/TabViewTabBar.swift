//
//  TabViewTabBar.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 5/10/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TabViewTabBar: UIView {

    var pages: [TabViewPage]? {
        didSet {
            if let pages = pages {
                var tabs = [TabViewTab]()
                for page in pages {
                    let tab = TabViewTab()
                    tab.isSelected = tab == tabs.first
                    tab.title = page.title
                    tab.onTap = { [weak self] in
                        self?.didTap(page)
                    }
                    tabs.append(tab)
                }
                self.tabs = tabs
                accessibilityValue = tabs.first?.accessibilityLabel
            } else {
                self.tabs = nil
            }
            selectedIndex = 0
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            updateDisplay()
        }
    }
    
    var onPageSelected: ((_ page: TabViewPage, _ index: Int) -> Void)?
    
    // MARK: Private Properties
    
    private var tabs: [TabViewTab]? {
        didSet {
            if let oldTabs = oldValue {
                for oldTab in oldTabs {
                    oldTab.removeFromSuperview()
                }
            }
            
            if let tabs = tabs {
                for tab in tabs {
                    addSubview(tab)
                }
            }
            
            setNeedsLayout()
        }
    }
    
    private let shadowView = UIView()
    
    // MARK: Initialization
    
    func commonInit() {
        clipsToBounds = true
        
        backgroundColor = ASAPP.styles.colors.backgroundPrimary
        
        shadowView.backgroundColor = ASAPP.styles.colors.backgroundPrimary
        applyShadowToView(shadowView)
        addSubview(shadowView)
        
        updateDisplay()
        
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.adjustable
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Layout
    
    func getFramesThatFit(_ size: CGSize) -> [CGRect] {
        guard let tabs = tabs else {
            return [CGRect.zero]
        }
        
        let tabWidth = floor(size.width / CGFloat(tabs.count))
        let tabWidthExtraPixels = size.width - CGFloat(tabs.count) * tabWidth
        
        var frames = [CGRect]()
        var left: CGFloat = 0.0
        var maxHeight: CGFloat = 0.0
        for tab in tabs {
            let thisTabWidth = tab == tabs.first ? tabWidth + tabWidthExtraPixels : tabWidth
            let tabHeight = ceil(tab.sizeThatFits(CGSize(width: thisTabWidth, height: 0)).height)
            let frame = CGRect(x: left, y: 0, width: thisTabWidth, height: tabHeight)
            frames.append(frame)
            left = frame.maxX
            maxHeight = max(maxHeight, frame.height)
        }
        
        for (idx, frame) in frames.enumerated() {
            var mutableFrame = frame
            mutableFrame.size.height = maxHeight
            frames[idx] = mutableFrame
        }
    
        return frames
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        if let tabs = tabs {
            let frames = getFramesThatFit(bounds.size)
            for (idx, tab) in tabs.enumerated() {
                tab.frame = frames[idx]
            }
        }
        
        shadowView.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 1)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var maxSize = CGSize.zero
        
        let frames = getFramesThatFit(size)
        for frame in frames {
            maxSize.width = max(maxSize.width, frame.maxX)
            maxSize.height = max(maxSize.height, frame.maxY)
        }
        
        return maxSize
    }
    
    // MARK: - Actions
    
    override func accessibilityDecrement() {
        if selectedIndex > 0 {
            selectedIndex -= 1
        }
    }
    
    override func accessibilityIncrement() {
        if selectedIndex < (pages?.count ?? 0) - 1 {
            selectedIndex += 1
        }
    }
    
    func updateDisplay() {
        guard let tabs = tabs else {
            return
        }
        
        for (tabIndex, tab) in tabs.enumerated() {
            if tabIndex == selectedIndex {
                bringSubviewToFront(shadowView)
                bringSubviewToFront(tab)
                
                tab.isSelected = true
                applyShadowToView(tab)
                bringSubviewToFront(tab)
                
                accessibilityValue = tab.accessibilityLabel
            } else {
                tab.isSelected = false
                removeShadowFromView(tab)
            }
            
            tab.showSeparatorLeft = tabIndex > 0 && (tabIndex < selectedIndex || tabIndex > selectedIndex + 1)
        }
    }
    
    private func didTap(_ page: TabViewPage) {
        if let pageIndex = pages?.index(of: page) {
            selectedIndex = pageIndex
            onPageSelected?(page, pageIndex)
        }
    }
    
    private func applyShadowToView(_ view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = .zero
    }
    private func removeShadowFromView(_ view: UIView) {
        view.layer.shadowColor = nil
        view.layer.shadowOpacity = 0.0
    }
}
