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
    
    fileprivate let scrollView = UIScrollView()
    
    fileprivate let pageControlView = PageControlView()
    
    fileprivate var touchPassThroughView: TouchPassThroughView!
    
    fileprivate(set) var cardViews: [ComponentView]? {
        didSet {
            for subview in scrollView.subviews {
                subview.removeFromSuperview()
            }
            
            if let cardViews = cardViews {
                for cardView in cardViews {
                    scrollView.addSubview(cardView.view)
                }
            }
            
            setNeedsLayout()
        }
    }
    
    var numberOfPages: Int {
        return cardViews?.count ?? 0
    }
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            guard let carousel = carouselViewItem else {
                self.cardViews = nil
                pageControlView.numberOfPages = 0
                return
            }

            var cardViews = [ComponentView]()
            for card in carousel.cards {
                var cardView = card.createView()
                cardView?.interactionHandler = interactionHandler
                cardView?.contentHandler = contentHandler
                if let cardView = cardView {
                    cardViews.append(cardView)
                }
            }
            self.cardViews = cardViews
            
            scrollView.isPagingEnabled = carousel.pagingEnabled
            
            pageControlView.component = carouselViewItem?.pageControlItem
            pageControlView.numberOfPages = numberOfPages
            pageControlView.currentPage = 0
            
            updateCarouselValue()
            
            setNeedsLayout()
        }
    }
    
    override var nestedComponentViews: [ComponentView]? {
        var nestedComponentViews = [ComponentView]()
        if let cardViews = cardViews {
            nestedComponentViews.append(contentsOf: cardViews)
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
        var cardFrames = [CGRect]()
        var contentSize = CGSize.zero
        var pageControlFrame = CGRect.zero
        guard let carousel = carouselViewItem,
            let cardViews = cardViews else {
                return (scrollViewFrame, cardFrames, contentSize, pageControlFrame)
        }
        
        // Get Available Size
        var fitToSize = size
        if fitToSize.height == 0 {
            fitToSize.height = UIScreen.main.bounds.height
        }
        if fitToSize.width == 0 {
            fitToSize.width = UIScreen.main.bounds.width
        }
        fitToSize.width -= carousel.style.padding.left + carousel.style.padding.right
        fitToSize.height -= carousel.style.padding.top + carousel.style.padding.bottom
        guard fitToSize.width > 0 && fitToSize.height > 0 else {
            return (scrollViewFrame, cardFrames, contentSize, pageControlFrame)
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
        
        // Sizing Cards
        let padding = carousel.style.padding
        let negativeContentWidth = max(0, ceil(carousel.cardDisplayCount) - 1) * carousel.cardSpacing
        let visibleCardContentWidth = fitToSize.width - negativeContentWidth
        let cardWidth = ceil(visibleCardContentWidth / carousel.cardDisplayCount)
        guard cardWidth > 0 else {
            return (scrollViewFrame, cardFrames, contentSize, pageControlFrame)
        }
        
        // Set frames horizontally
        var cardLeft: CGFloat = 0
        if carousel.pagingEnabled {
            cardLeft = floor(carousel.cardSpacing / 2.0)
        }
        for cardView in cardViews {
            let cardHeight = ceil(cardView.view.sizeThatFits(CGSize(width: cardWidth, height: 0)).height)
            let cardFrame = CGRect(x: cardLeft, y: 0, width: cardWidth, height: cardHeight)
            cardFrames.append(cardFrame)
            
            contentSize.width = max(contentSize.width, cardFrame.maxX)
            contentSize.height = max(contentSize.height, cardFrame.maxY)
            cardLeft += cardWidth + carousel.cardSpacing
        }
        
        // TODO: Align frames vertically, if necessary
        let scrollViewWidth = carousel.pagingEnabled ? cardWidth + carousel.cardSpacing : visibleCardContentWidth
        scrollViewFrame = CGRect(x: padding.left, y: padding.top, width: scrollViewWidth, height: contentSize.height)

        
        
        // Set Page Control Top if Carousel is gravity!=fill
        if pcHeight > 0 && carousel.style.gravity != .fill {
            pcTop = scrollViewFrame.maxY + pcMargin.top
            pageControlFrame = CGRect(x: pcLeft, y: pcTop, width: pcWidth, height: pcHeight)
        }
        
        return (scrollViewFrame, cardFrames, contentSize, pageControlFrame)
    }
    
    override func updateFrames() {
        touchPassThroughView.frame = bounds
        guard let cardViews = cardViews else {
            return
        }
        
        let (scrollViewFrame, cardFrames, contentSize, pageControlFrame) = getFramesThatFit(bounds.size)
        scrollView.frame = scrollViewFrame
        if cardViews.count == cardFrames.count {
            for (idx, cardView) in cardViews.enumerated() {
                cardView.view.frame = cardFrames[idx]
            }
        }
        scrollView.contentSize = contentSize
        pageControlView.frame = pageControlFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let component = component else {
            return .zero
        }
        
        let (scrollViewFrame, _, _, pageControlFrame) = getFramesThatFit(size)
        let contentHeight = max(scrollViewFrame.maxY, pageControlFrame.maxY) + component.style.padding.bottom
        return CGSize(width: size.width, height: contentHeight)
    }
}

extension CarouselView: UIScrollViewDelegate {
    
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
            contentHandler?.componentView(self,
                                          didUpdateContent: carouselViewItem,
                                          requiresLayoutUpdate: false)
        }
    }
    
    func updateCarouselValue() {
        let currentPage = pageControlView.currentPage
        guard let carouselViewItem = carouselViewItem,
            currentPage >= 0 && currentPage < carouselViewItem.cards.count else {
                return
        }
        
        let currentCard = carouselViewItem.cards[currentPage]
        self.carouselViewItem?.value = currentCard.value
        
        DebugLog.d(caller: self, "Updated carousel value to: \(String(describing: carouselViewItem.value))")
        
        if let quickReplies = carouselViewItem.quickReplies {
            
            var titles = [String]()
            for quickReply in quickReplies {
                titles.append(quickReply.title)
            }
            print("\n\n\nQuick Replies: [\(titles.joined(separator: ", "))]")
        }
        
    }
}
