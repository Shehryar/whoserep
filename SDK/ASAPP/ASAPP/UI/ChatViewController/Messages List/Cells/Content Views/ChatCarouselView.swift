//
//  ChatCarouselView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/10/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol ChatCarouselViewDelegate: class {
    func chatCarouselView(_ view: ChatCarouselView, didTap button: QuickReply)
    func chatCarouselView(_ view: ChatCarouselView, didChangeCurrentPage page: Int)
}

class ChatCarouselView: UIView {
    weak var delegate: ChatCarouselViewDelegate?
    weak var interactionHandler: InteractionHandler?
    weak var contentHandler: ComponentViewContentHandler?
    
    var numberOfPages: Int {
        return containerViews?.count ?? 0
    }
    
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private var touchPassThroughView: TouchPassThroughView!
    
    private let itemSpacing: CGFloat = 6
    private let pageControlHeight: CGFloat = 34
    private let maxCardWidth: CGFloat = 260
    
    private(set) var containerViews: [ComponentCardView]? {
        didSet {
            for subview in scrollView.subviews {
                subview.removeFromSuperview()
            }
            
            if let itemViews = containerViews {
                for itemView in itemViews {
                    scrollView.addSubview(itemView)
                }
            }
            
            setNeedsLayout()
        }
    }
    
    func update(for carousel: ChatMessageCarousel?) {
        guard let carousel = carousel,
              !carousel.elements.isEmpty else {
            self.containerViews = nil
            pageControl.numberOfPages = 0
            return
        }
        
        var containerViews = [ComponentCardView]()
        for container in carousel.elements {
            let containerView = ComponentCardView()
            containerView.delegate = self
            containerView.interactionHandler = interactionHandler
            containerView.contentHandler = contentHandler
            containerView.component = container.root
            containerViews.append(containerView)
        }
        self.containerViews = containerViews
        
        scrollView.isPagingEnabled = true
        
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = ASAPP.styles.colors.controlTint
        pageControl.pageIndicatorTintColor = ASAPP.styles.colors.controlSecondary
        pageControl.addTarget(self, action: #selector(paged), for: .valueChanged)
        
        setNeedsLayout()
        updateFrames()
    }
    
    func updateCardButtons(_ arraysOfButtons: [[QuickReply]]?) {
        guard let arraysOfButtons = arraysOfButtons,
              let cards = containerViews,
              arraysOfButtons.count == cards.count else {
            for card in containerViews ?? [] {
                card.messageButtonsView?.removeFromSuperview()
                card.messageButtonsView = nil
            }
            return
        }
        
        for (card, buttons) in zip(cards, arraysOfButtons) {
            card.messageButtonsView = MessageButtonsView(messageButtons: buttons)
            card.setNeedsLayout()
        }
        
        setNeedsLayout()
        updateFrames()
    }
    
    @objc func paged() {
        let page = pageControl.currentPage
        guard page >= 0,
              page < numberOfPages,
              page != scrollView.currentPage else {
            return
        }
        
        showPage(page, animated: true)
        delegate?.chatCarouselView(self, didChangeCurrentPage: page)
    }
    
    func showPage(_ page: Int, animated: Bool = false) {
        guard page >= 0,
              page < numberOfPages,
              page != scrollView.currentPage else {
            return
        }
        
        let offsetX = CGFloat(page) * scrollView.bounds.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
    }
    
    // MARK: Init
    
    func commonInit() {
        clipsToBounds = false
        
        self.touchPassThroughView = TouchPassThroughView(withTargetView: scrollView)
        addSubview(touchPassThroughView)
        
        scrollView.scrollsToTop = false
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
        
        addSubview(pageControl)
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
    
    // MARK: Layout
    
    private struct CalculatedLayout {
        let scrollViewFrame: CGRect
        let itemFrames: [CGRect]
        let contentSize: CGSize
        let pageControlFrame: CGRect
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        var scrollViewFrame = CGRect.zero
        var itemFrames = [CGRect]()
        var contentSize = CGSize.zero
        var pageControlFrame = CGRect.zero
        guard let itemViews = containerViews else {
            return CalculatedLayout(scrollViewFrame: scrollViewFrame, itemFrames: itemFrames, contentSize: contentSize, pageControlFrame: pageControlFrame)
        }
        
        // Get Available Size
        var fitToSize = size
        fitToSize.width = size.width > 0 ? size.width : UIScreen.main.bounds.width
        fitToSize.height = size.height > 0 ? size.height : UIScreen.main.bounds.height
        guard fitToSize.width > 0 && fitToSize.height > 0 else {
            return CalculatedLayout(scrollViewFrame: scrollViewFrame, itemFrames: itemFrames, contentSize: contentSize, pageControlFrame: pageControlFrame)
        }
        
        // Sizing Items
        let itemWidth = min(fitToSize.width, maxCardWidth)
        guard itemWidth > 0 else {
            return CalculatedLayout(scrollViewFrame: scrollViewFrame, itemFrames: itemFrames, contentSize: contentSize, pageControlFrame: pageControlFrame)
        }
        
        // Set frames horizontally
        var itemLeft: CGFloat = 0
        
        let maxItemHeight = fitToSize.height - pageControlHeight
        for itemView in itemViews {
            let itemHeight = ceil(itemView.sizeThatFits(CGSize(width: itemWidth, height: maxItemHeight)).height)
            let itemFrame = CGRect(x: itemLeft, y: 0, width: itemWidth, height: itemHeight)
            itemFrames.append(itemFrame)
            
            contentSize.width = max(contentSize.width, itemFrame.maxX)
            contentSize.height = max(contentSize.height, itemFrame.maxY)
            itemLeft += itemWidth + itemSpacing
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
                    
                case .bottom:
                    frame.origin.y = contentSize.height - frame.size.height
                    
                case .fill:
                    frame.size.height = contentSize.height
                }
            }
            itemFrames[idx] = frame
        }
        
        let scrollViewWidth = itemWidth + itemSpacing
        scrollViewFrame = CGRect(x: 0, y: 0, width: scrollViewWidth, height: contentSize.height)
        
        pageControlFrame = CGRect(x: 0, y: scrollViewFrame.maxY, width: size.width, height: pageControlHeight)
        
        return CalculatedLayout(scrollViewFrame: scrollViewFrame, itemFrames: itemFrames, contentSize: contentSize, pageControlFrame: pageControlFrame)
    }
    
    func updateFrames() {
        touchPassThroughView.frame = bounds
        guard let itemViews = containerViews else {
            return
        }
        
        let layout = getFramesThatFit(bounds.size)
        scrollView.frame = layout.scrollViewFrame
        if itemViews.count == layout.itemFrames.count {
            for (i, itemView) in itemViews.enumerated() {
                itemView.frame = layout.itemFrames[i]
            }
        }
        scrollView.contentSize = layout.contentSize
        pageControl.frame = layout.pageControlFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var fitToSize = size
        fitToSize.width = size.width > 0 ? size.width : UIScreen.main.bounds.width
        fitToSize.height = size.height > 0 ? size.height : UIScreen.main.bounds.height
        
        let layout = getFramesThatFit(fitToSize)
        let contentHeight = max(layout.scrollViewFrame.maxY, layout.pageControlFrame.maxY)
        return CGSize(width: fitToSize.width, height: min(fitToSize.height, contentHeight))
    }
}

extension ChatCarouselView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else {
            return
        }
        
        let currentPage = scrollView.currentPage
        if currentPage != pageControl.currentPage {
            pageControl.currentPage = currentPage
            delegate?.chatCarouselView(self, didChangeCurrentPage: currentPage)
        }
    }
}

extension ChatCarouselView: MessageButtonsViewContainerDelegate {
    func messageButtonsViewContainer(_ messageButtonsViewContainer: MessageButtonsViewContainer, didTap button: QuickReply) {
        delegate?.chatCarouselView(self, didTap: button)
    }
}
