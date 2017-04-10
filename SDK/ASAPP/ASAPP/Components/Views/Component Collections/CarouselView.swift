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
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            var cardViews = [ComponentView]()
            if let carousel = carouselViewItem {
                scrollView.isPagingEnabled = carousel.pagingEnabled
                
                for card in carousel.cards {
                    var cardView = card.createView()
                    cardView?.interactionHandler = interactionHandler
                    if let cardView = cardView {
                        cardViews.append(cardView)
                    }
                }
            }
            self.cardViews = cardViews
        }
    }
    
    var carouselViewItem: CarouselViewItem? {
        return component as? CarouselViewItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        self.touchPassThroughView = TouchPassThroughView(withTargetView: scrollView)
        
        clipsToBounds = false
        
        scrollView.scrollsToTop = false
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        addSubview(touchPassThroughView)
    }
    
    // MARK: Layout
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, [CGRect], CGSize) {
        var scrollViewFrame = CGRect.zero
        var cardFrames = [CGRect]()
        var contentSize = CGSize.zero
        guard let carousel = carouselViewItem,
            let cardViews = cardViews else {
                return (scrollViewFrame, cardFrames, contentSize)
        }
        
        let padding = carousel.style.padding
        let totalWidth = size.width > 0 ? size.width : CGFloat.greatestFiniteMagnitude
        let contentWidth = totalWidth - padding.left - padding.right
        let negativeContentWidth = max(0, ceil(carousel.cardDisplayCount) - 1) * carousel.cardSpacing
        let visibleCardContentWidth = contentWidth - negativeContentWidth
        let cardWidth = ceil(visibleCardContentWidth / carousel.cardDisplayCount)
        guard cardWidth > 0 else {
            return (scrollViewFrame, cardFrames, contentSize)
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
        
        return (scrollViewFrame, cardFrames, contentSize)
    }
    
    override func updateFrames() {
        touchPassThroughView.frame = bounds
        guard let cardViews = cardViews else {
            return
        }
        
        let (scrollViewFrame, cardFrames, contentSize) = getFramesThatFit(bounds.size)
        scrollView.frame = scrollViewFrame
        if cardViews.count == cardFrames.count {
            for (idx, cardView) in cardViews.enumerated() {
                cardView.view.frame = cardFrames[idx]
            }
        }
        scrollView.contentSize = contentSize
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let component = component else {
            return .zero
        }
        
        let (scrollViewFrame, _, _) = getFramesThatFit(size)
        let contentHeight = scrollViewFrame.maxY + component.style.padding.bottom
        return CGSize(width: size.width, height: contentHeight)
    }

    // MARK: Interaction Handler
    
    override func updateSubviewsWithInteractionHandler() {
        super.updateSubviewsWithInteractionHandler()
        
        for (idx, _) in subviews.enumerated() {
            var view = subviews[idx] as? ComponentView
            view?.interactionHandler = self.interactionHandler
        }
    }
}
