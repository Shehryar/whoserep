//
//  CarouselView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/10/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class CarouselView: BaseComponentView {

    // MARK: Properties
    
    private let scrollView = UIScrollView()
    
    private let pageControlView = PageControlView()
    
    private var touchPassThroughView: TouchPassThroughView!
    
    private(set) var itemViews: [ComponentView]? {
        didSet {
            for subview in scrollView.subviews {
                subview.removeFromSuperview()
            }
            
            if let itemViews = itemViews {
                for itemView in itemViews {
                    scrollView.addSubview(itemView.view)
                }
            }
            
            setNeedsLayout()
        }
    }
    
    var numberOfPages: Int {
        return itemViews?.count ?? 0
    }
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            guard let carousel = carouselViewItem else {
                self.itemViews = nil
                pageControlView.numberOfPages = 0
                return
            }

            var itemViews = [ComponentView]()
            for item in carousel.items {
                var itemView = item.createView()
                itemView?.interactionHandler = interactionHandler
                itemView?.contentHandler = contentHandler
                if let itemView = itemView {
                    itemViews.append(itemView)
                }
            }
            self.itemViews = itemViews
            
            scrollView.isPagingEnabled = carousel.pagingEnabled
            
            pageControlView.component = carouselViewItem?.pageControlItem
            pageControlView.numberOfPages = numberOfPages
            pageControlView.currentPage = 0
            
            if getPageIndexOfCurrentValue() == nil {
                updateCarouselValue()
            }
            
            setNeedsLayout()
        }
    }
    
    override var nestedComponentViews: [ComponentView]? {
        var nestedComponentViews = [ComponentView]()
        if let itemViews = itemViews {
            nestedComponentViews.append(contentsOf: itemViews)
        }
        nestedComponentViews.append(pageControlView)
        return nestedComponentViews
    }
    
    var carouselViewItem: CarouselViewItem? {
        return component as? CarouselViewItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        clipsToBounds = false
        
        self.touchPassThroughView = TouchPassThroughView(withTargetView: scrollView)
        addSubview(touchPassThroughView)
        
        scrollView.scrollsToTop = false
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
        
        pageControlView.onPageUpdateTap = { [weak self] (page) in
            self?.scrollToPage(page)
        }
        addSubview(pageControlView)
    }
    
    deinit {
        scrollView.delegate = nil
    }
    
    // MARK: Layout
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, [CGRect], CGSize, CGRect) {
        var scrollViewFrame = CGRect.zero
        var itemFrames = [CGRect]()
        var contentSize = CGSize.zero
        var pageControlFrame = CGRect.zero
        guard let carousel = carouselViewItem,
            let itemViews = itemViews else {
                return (scrollViewFrame, itemFrames, contentSize, pageControlFrame)
        }
        
        // Get Available Size
        var fitToSize = size
        fitToSize.width = size.width > 0 ? size.width : UIScreen.main.bounds.width
        fitToSize.height = size.height > 0 ? size.height : UIScreen.main.bounds.height
        fitToSize.width -= carousel.style.padding.left + carousel.style.padding.right
        fitToSize.height -= carousel.style.padding.top + carousel.style.padding.bottom
        guard fitToSize.width > 0 && fitToSize.height > 0 else {
            return (scrollViewFrame, itemFrames, contentSize, pageControlFrame)
        }
        
        // Size Page Control
        var pcLeft: CGFloat = 0
        var pcWidth: CGFloat = 0
        var pcHeight: CGFloat = 0
        var pcTop: CGFloat = 0
        var pcMargin: UIEdgeInsets = .zero
        if let pageControlItem = carouselViewItem?.pageControlItem {
            pcMargin = pageControlItem.style.margin
            pcLeft = carousel.style.padding.left + pcMargin.left
            let pcRight = carousel.style.padding.left + fitToSize.width - pcMargin.right
            pcWidth = max(0, pcRight - pcLeft)
            if pcWidth > 0 {
                pcHeight = ceil(pageControlView.sizeThatFits(CGSize(width: pcWidth, height: 0)).height)
            }
        }
        
        // Set Page Control Top if Carousel is gravity==fill
        if pcHeight > 0 && carousel.style.gravity == .fill {
            pcTop = carousel.style.padding.top + fitToSize.height - pcMargin.bottom - pcHeight
            pageControlFrame = CGRect(x: pcLeft, y: pcTop, width: pcWidth, height: pcHeight)
            fitToSize.height -= pcHeight + pcMargin.top + pcMargin.bottom
        }
        
        // Sizing Items
        let padding = carousel.style.padding
        let negativeContentWidth = max(0, ceil(carousel.visibleItemCount) - 1) * carousel.itemSpacing
        let visibleItemContentWidth = fitToSize.width - negativeContentWidth
        var itemWidth = ceil(visibleItemContentWidth / carousel.visibleItemCount)
        guard itemWidth > 0 else {
            return (scrollViewFrame, itemFrames, contentSize, pageControlFrame)
        }
        
        // Set frames horizontally
        var itemLeft: CGFloat = 0
        if carousel.pagingEnabled {
            if carousel.visibleItemCount <= 1 {
                itemWidth -= carousel.itemSpacing
            }
            itemLeft = floor(carousel.itemSpacing / 2.0)
        }
        
        let maxItemHeight = fitToSize.height - pcHeight - pcMargin.top - pcMargin.bottom
        for itemView in itemViews {
            let itemHeight = ceil(itemView.view.sizeThatFits(CGSize(width: itemWidth, height: maxItemHeight)).height)
            let itemFrame = CGRect(x: itemLeft, y: 0, width: itemWidth, height: itemHeight)
            itemFrames.append(itemFrame)
            
            contentSize.width = max(contentSize.width, itemFrame.maxX)
            contentSize.height = max(contentSize.height, itemFrame.maxY)
            itemLeft += itemWidth + carousel.itemSpacing
        }
        
        // Align frames vertically, if necessary
        for (idx, itemView) in itemViews.enumerated() {
            var frame = itemFrames[idx]
            if let gravity = itemView.component?.style.gravity {
                switch gravity {
                case .top:
                    // No-op
                    break
                    
                case .middle:
                    frame.origin.y = floor((contentSize.height - frame.size.height) / 2.0)
                    break
                    
                case .bottom:
                    frame.origin.y = contentSize.height - frame.size.height
                    break
                    
                case .fill:
                    frame.size.height = contentSize.height
                    break
                }
            }
            itemFrames[idx] = frame
        }
        
        let scrollViewWidth = carousel.pagingEnabled ? itemWidth + carousel.itemSpacing : visibleItemContentWidth
        scrollViewFrame = CGRect(x: padding.left, y: padding.top, width: scrollViewWidth, height: contentSize.height)

        // Set Page Control Top if Carousel is gravity!=fill
        if pcHeight > 0 && carousel.style.gravity != .fill {
            pcTop = scrollViewFrame.maxY + pcMargin.top
            pageControlFrame = CGRect(x: pcLeft, y: pcTop, width: pcWidth, height: pcHeight)
        }
        
        return (scrollViewFrame, itemFrames, contentSize, pageControlFrame)
    }
    
    override func updateFrames() {
        touchPassThroughView.frame = bounds
        guard let itemViews = itemViews else {
            return
        }
        
        let (scrollViewFrame, itemFrames, contentSize, pageControlFrame) = getFramesThatFit(bounds.size)
        scrollView.frame = scrollViewFrame
        if itemViews.count == itemFrames.count {
            for (idx, itemView) in itemViews.enumerated() {
                itemView.view.frame = itemFrames[idx]
            }
        }
        scrollView.contentSize = contentSize
        pageControlView.frame = pageControlFrame
        
        if let currentPage = getPageIndexOfCurrentValue() {
            pageControlView.currentPage = currentPage
            let offset = CGFloat(currentPage) * scrollView.bounds.width
            scrollView.contentOffset = CGPoint(x: offset, y: 0)
        }
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let component = component else {
            return .zero
        }
        
        var fitToSize = size
        fitToSize.width = size.width > 0 ? size.width : UIScreen.main.bounds.width
        fitToSize.height = size.height > 0 ? size.height : UIScreen.main.bounds.height
        
        let (scrollViewFrame, _, _, pageControlFrame) = getFramesThatFit(fitToSize)
        let contentHeight = max(scrollViewFrame.maxY, pageControlFrame.maxY) + component.style.padding.bottom
        return CGSize(width: fitToSize.width, height: min(fitToSize.height, contentHeight))
    }
}

extension CarouselView: UIScrollViewDelegate {
    
    func getPageIndexOfCurrentValue() -> Int? {
        guard let component = component, let itemViews = itemViews else {
            return nil
        }
        
        for (idx, itemView) in itemViews.enumerated() {
            if component.valueEquals(itemView.component?.value) {
                return idx
            }
        }
        return nil
    }
    
    func scrollToPage(_ page: Int, animated: Bool = true) {
        guard page >= 0 && page < numberOfPages else {
            return
        }
        guard page != scrollView.currentPage else {
            return
        }
        
        let offsetX = CGFloat(page) * scrollView.bounds.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
        
        handlePageChange()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else {
            return
        }
        
        let currentPage = scrollView.currentPage
        if currentPage != pageControlView.currentPage {
            pageControlView.currentPage = currentPage
            
            handlePageChange()
        }
    }
    
    func handlePageChange() {
        updateCarouselValue()
        
        if let carouselViewItem = carouselViewItem {
            
            contentHandler?.componentView(self, didPageCarousel: carouselViewItem)
        }
    }
    
    func updateCarouselValue() {
        let currentPage = pageControlView.currentPage
        guard let carouselViewItem = carouselViewItem,
            carouselViewItem.pagingEnabled &&
            currentPage >= 0 && currentPage < carouselViewItem.items.count else {
                return
        }
        
        let currentItem = carouselViewItem.items[currentPage]
        self.carouselViewItem?.value = currentItem.value
        
        DebugLog.d(caller: self, "Updated carousel value to: \(String(describing: carouselViewItem.value))")
    }
}
