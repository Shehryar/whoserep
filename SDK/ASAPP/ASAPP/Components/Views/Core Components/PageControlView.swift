//
//  PageControlView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/11/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class PageControlView: BaseComponentView {

    var numberOfPages: Int = 0 {
        didSet {
            pageControl.numberOfPages = numberOfPages
            setNeedsLayout()
        }
    }
    
    var currentPage: Int {
        set {
            pageControl.currentPage = newValue
        }
        get {
            return pageControl.currentPage
        }
    }
    
    var onPageUpdateTap: ((Int) -> Void)?
    
    // MARK: UI Properties
    
    fileprivate let pageControl = UIPageControl()
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            pageControl.currentPageIndicatorTintColor = component?.style.color
                ?? ASAPP.styles.controlTintColor
            
            pageControl.pageIndicatorTintColor = ASAPP.styles.controlSecondaryColor
            pageControl.addTarget(self, action: #selector(PageControlView.onPageChange), for: .valueChanged)
            setNeedsLayout()
        }
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        

        addSubview(pageControl)
    }
    
    // MARK: Actions
    
    func onPageChange() {
        onPageUpdateTap?(pageControl.currentPage)
    }
    
    // MARK: Layout
    
    func getPageControlFrameThatFits(_ size: CGSize) -> CGRect {
        guard let style = component?.style, numberOfPages > 0 else {
            return .zero
        }
        
        var fitToSize = size
        if fitToSize.height == 0 {
            fitToSize.height = CGFloat.greatestFiniteMagnitude
        }
        if fitToSize.width == 0 {
            fitToSize.width = UIScreen.main.bounds.width
        }
        fitToSize.width -= style.padding.left + style.padding.right
        fitToSize.height -= style.padding.top + style.padding.bottom
        
        guard fitToSize.width > 0 && fitToSize.height > 0 else {
            return .zero
        }
        
        var pageControlSize = pageControl.sizeThatFits(fitToSize)
        
        /***
         Fucking bug with Apple's code... UIPageControl returns 0 width despite having a valid number of pages.
 
        // pageControlSize.width = ceil(pageControlSize.width)
         */
        pageControlSize.width = fitToSize.width
        pageControlSize.height = ceil(pageControlSize.height)
        
        guard pageControlSize.height > 0 && pageControlSize.width > 0 else {
            return .zero
        }
        
        let left: CGFloat
        let width: CGFloat
        switch style.alignment {
        case .center, .fill:
            left = style.padding.left
            width = fitToSize.width
            break
            
        case .left:
            left = style.padding.left
            width = pageControlSize.width
            break
            
        case .right:
            left = style.padding.left + fitToSize.width - pageControlSize.width
            width = pageControlSize.width
            break
        }
        
        return CGRect(x: left, y: style.padding.top, width: width, height: pageControlSize.height)
    }
    
    override func updateFrames() {
        pageControl.frame = getPageControlFrameThatFits(bounds.size)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let component = component else {
            return .zero
        }
        
        let pageControlFrame = getPageControlFrameThatFits(size)
        guard pageControlFrame.height > 0 else {
            return .zero
        }
        
        let height = pageControlFrame.maxY + component.style.padding.bottom
        return CGSize(width: size.width, height: height)
    }
}
