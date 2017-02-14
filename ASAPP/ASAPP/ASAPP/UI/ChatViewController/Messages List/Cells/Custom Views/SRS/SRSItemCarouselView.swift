//
//  SRSItemCarouselView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol SRSItemCarouselViewDelegate: class {
    func itemCarouselView(_ itemCarouselView: SRSItemCarouselView, didScrollToPage page: Int)
    func itemCarouselView(_ itemCarouselView: SRSItemCarouselView, didSelectButtonItem buttonItem: SRSButtonItem)
}

class SRSItemCarouselView: UIView {

    // Used for reference only
    var event: Event?
    
    var itemCarousel: SRSItemCarousel? {
        didSet {
            reloadPageViews()
        }
    }
    
    var maxPageWidth: CGFloat = 200 {
        didSet {
            setNeedsLayout()
        }
    }
    
    weak var delegate: SRSItemCarouselViewDelegate?
    
    // MARK: UI Properties
    
    fileprivate let scrollView = UIScrollView()
    
    fileprivate var touchPassThroughView: TouchPassThroughView?
    
    fileprivate let pageControl = UIPageControl()
    
    fileprivate let pageSpacing: CGFloat = 10.0
    
    fileprivate let pageControlMargin: CGFloat = 2
    
    fileprivate var pageViews = [SRSItemListView]()
    
    // MARK: Init
    
    func commonInit() {
        scrollView.clipsToBounds = false
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        addSubview(scrollView)
        
        touchPassThroughView = TouchPassThroughView(withTargetView: scrollView)
        addSubview(touchPassThroughView!)
        
        pageControl.hidesForSinglePage = true
        pageControl.addTarget(self, action: #selector(SRSItemCarouselView.pageControlDidChange), for: .valueChanged)
        addSubview(pageControl)
        
        applyStyles(styles)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        scrollView.delegate = nil
    }
    
    // MARK: ASAPPStyleable
    
    fileprivate(set) var styles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
     
        for pageView in pageViews {
            pageView.applyStyles(styles)
        }
        
        pageControl.currentPageIndicatorTintColor = styles.foregroundColor1.withAlphaComponent(0.4)
        pageControl.pageIndicatorTintColor = styles.foregroundColor2.withAlphaComponent(0.4)
        
        setNeedsLayout()
    }
    
    // MARK: Updating Views
    
    func reloadPageViews() {
        for pageView in pageViews {
            pageView.delegate = nil
            pageView.removeFromSuperview()
        }
        pageViews.removeAll()
        scrollView.contentOffset = CGPoint.zero
        pageControl.numberOfPages = 0
        
        guard let itemCarousel = itemCarousel else {
            return
        }
        
        for itemList in itemCarousel.pages {
            let itemListView = SRSItemListView()
            itemListView.applyStyles(styles)
            itemListView.itemList = itemList
            itemListView.delegate = self
            pageViews.append(itemListView)
            scrollView.addSubview(itemListView)
        }
        pageControl.numberOfPages = pageViews.count
        updatePageViewAlphas()
        
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    func pageWidthThatFits(_ size: CGSize, maximumPageWidth: CGFloat) -> CGFloat {
        var pageWidth = size.width - pageSpacing
        if pageWidth > maximumPageWidth {
            pageWidth = maximumPageWidth
        }
        return pageWidth
    }
    
    func pageControlHeightMarginForWidth(_ width: CGFloat) -> (CGFloat, CGFloat) {
        var pageControlHeight: CGFloat = 0.0
        var pageControlMargin: CGFloat = 0.0
        if pageViews.count > 1 {
            pageControlHeight = ceil(pageControl.sizeThatFits(CGSize(width: width, height: 0)).height)
            pageControlMargin = self.pageControlMargin
        }
        return (pageControlHeight, pageControlMargin)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let pageWidth = pageWidthThatFits(bounds.size, maximumPageWidth: maxPageWidth)
        
        let (pageControlHeight, pageControlMargin) = pageControlHeightMarginForWidth(pageWidth)
        let pageControlTop = bounds.height - pageControlHeight
        pageControl.frame = CGRect(x: 0, y: pageControlTop, width: pageWidth, height: pageControlHeight)
        
        let scrollViewHeight = bounds.height - pageControlHeight - pageControlMargin
        scrollView.frame = CGRect(x: 0.0, y: 0.0, width: pageWidth + pageSpacing, height: scrollViewHeight)
        touchPassThroughView?.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: scrollViewHeight)
        
        var currentOffset: CGFloat = 0.0
        for pageView in pageViews {
            pageView.frame = CGRect(x: currentOffset, y: 0.0,
                                    width: pageWidth,
                                    height: scrollView.bounds.height)
            currentOffset += pageWidth + pageSpacing
        }
        scrollView.contentSize = CGSize(width: currentOffset, height: scrollView.bounds.height)
        
        
        if let itemCarousel = itemCarousel {
            let offset = scrollView.bounds.width * CGFloat(itemCarousel.currentPage)
            scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
            pageControl.currentPage = itemCarousel.currentPage
        }
        
        updatePageViewAlphas()
    }
    
    func sizeThatFits(_ size: CGSize, maximumPageWidth: CGFloat) -> CGSize {
        var fittedHeight: CGFloat = 0.0
        let pageWidth = pageWidthThatFits(size, maximumPageWidth: maximumPageWidth)
        for pageView in pageViews {
            fittedHeight = max(pageView.sizeThatFits(CGSize(width: pageWidth, height: 0)).height, fittedHeight)
        }
        
        let (pageControlHeight, pageControlMargin) = pageControlHeightMarginForWidth(pageWidth)
        fittedHeight += pageControlHeight + pageControlMargin
        
        return CGSize(width: size.width, height: fittedHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        DebugLog("sizeThatFits: called in SRSItemCarouselView instead of sizeThatFits(size;maximumPageWidth:)")
            
        return sizeThatFits(size, maximumPageWidth: maxPageWidth)
    }
    
    // MARK: Actions
    
    func pageControlDidChange() {
        let offset = scrollView.bounds.width * CGFloat(pageControl.currentPage)
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        
        notifyDelegateIfPreviousPageIsDifferent(previousPage: nil)
    }
    
    func notifyDelegateIfPreviousPageIsDifferent(previousPage: Int?) {
        let currentPage = pageControl.currentPage
        guard currentPage >= 0 && currentPage < pageViews.count else {
            return
        }
        
        itemCarousel?.currentPage = currentPage
        if let previousPage = previousPage {
            if previousPage != currentPage {
                delegate?.itemCarouselView(self, didScrollToPage: currentPage)
            }
        } else {
            delegate?.itemCarouselView(self, didScrollToPage: currentPage)
        }
    }
}

extension SRSItemCarouselView: SRSItemListViewDelegate {
    
    func itemListView(_ itemListView: SRSItemListView, didSelectButtonItem buttonItem: SRSButtonItem) {
        delegate?.itemCarouselView(self, didSelectButtonItem: buttonItem)
    }
}

extension SRSItemCarouselView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePageViewAlphas()
        
        guard scrollView.isDragging else { return }
        
        let previousPage = pageControl.currentPage
        pageControl.currentPage = scrollView.currentPage
        notifyDelegateIfPreviousPageIsDifferent(previousPage: previousPage)
    }
    
    func updatePageViewAlphas() {
        let scrollOffset = scrollView.contentOffset.x
        let scrollWidth = scrollView.bounds.width
        let minAlpha: CGFloat = 0.4
        for pageView in pageViews {
            let pageOriginX = pageView.frame.minX
            let ratio = max(0, (abs(pageOriginX - scrollOffset) - 20.0) / scrollWidth)
            let alpha = 1.0 - ratio * (1.0 - minAlpha)
            pageView.alpha = alpha
        }
    }
}

extension UIScrollView {
    
    var currentPage: Int {
        return max(Int(0),
                   Int(floor((contentOffset.x + bounds.width / CGFloat(2.0)) / bounds.width)))
    }
}

// MARK:- Touch Pass-through View

class TouchPassThroughView: UIView {
    
    let targetView: UIView
    
    required init(withTargetView targetView: UIView) {
        self.targetView = targetView
        super.init(frame: CGRect.zero)
        
        isUserInteractionEnabled = true
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Touches
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return targetView.hitTest(point, with: event) ?? targetView
        }
        return hitView
    }
}
