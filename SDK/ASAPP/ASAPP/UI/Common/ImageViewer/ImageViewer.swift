//
//  ImageViewer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ImageViewer: UIViewController {

    // MARK: Properties: Public
    
    var presentFromView: UIView?
    
    var presentationImage: UIImage?
    
    var presentationImageContentMode: UIViewContentMode = .scaleAspectFill
    
    var presentationImageCornerRadius: CGFloat = 0
    
    // MARK: Properties: Readonly
    
    fileprivate(set) var images: [ImageViewerImage]
    
    fileprivate(set) var initialIndex: Int
    
    var currentImage: ImageViewerImage? {
        return currentImageViewController()?.image
    }
    
    var currentlyDisplayedImage: UIImage? {
        return currentImageViewController()?.imageView.image
    }
    
    var currentIndex: Int {
        if let currentImage = currentImage {
            return images.index(of: currentImage) ?? 0
        }
        return 0
    }
    
    fileprivate(set) var accessoryViewsHidden = false
    
    // MARK: Properties: Private
    
    /// Should be updated by the ImageViewerTransitionAnimator
    var shouldOverrideStatusBar = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    fileprivate var transitionAnimator = ImageViewerTransitionAnimator()
    
    fileprivate let controlsView = ImageViewerControlsView()
    
    fileprivate let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 10])
    
    // MARK: Initialization
    
    required init(withImages images: [ImageViewerImage], initialIndex: Int = 0) {
        self.images = images
        self.initialIndex = initialIndex
        if self.initialIndex >= self.images.count {
            self.initialIndex = 0
        }
        
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        modalPresentationCapturesStatusBarAppearance = true
        transitioningDelegate = transitionAnimator
        
        controlsView.onDismissButtonTap = {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        pageViewController.dataSource = nil
        pageViewController.delegate = nil
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear
        
        view.addSubview(pageViewController.view)
        view.addSubview(controlsView)
        
        if let initialImage = imageForPage(initialIndex) {
            if let initialViewController = newImageViewController(withImage: initialImage) {
                initialViewController.setImage(initialImage, placeholderImage: presentationImage)
                setCurrentlyDisplayedViewController(initialViewController, animated: false)
            }
        }
    }
    
    // MARK: Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        controlsView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 50)
        pageViewController.view.frame = view.bounds
    }
}

// MARK:- UIStatusBar

extension ImageViewer {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        if shouldOverrideStatusBar {
            return true
        }
        return super.prefersStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
}

// MARK:- Content Utilities

extension ImageViewer {
    func imageForPage(_ page: Int) -> ImageViewerImage? {
        if page >= 0 && page < images.count {
            return images[page]
        }
        return nil
    }
    
    func pageForImageViewController(_ imageViewController: UIViewController?) -> Int? {
        guard let imageViewController = imageViewController as? ImageViewerImageViewController else {
            return nil
        }
        
        if let imageViewControllerImage = imageViewController.image {
            return self.images.index(of: imageViewControllerImage)
        }
        return nil
    }
    
    func currentImageViewController() -> ImageViewerImageViewController? {
        return self.pageViewController.viewControllers?.first as? ImageViewerImageViewController
    }
    
    func newImageViewController(withImage image: ImageViewerImage?) -> ImageViewerImageViewController? {
        guard let image = image else {
            return nil
        }
        
        let imageViewController = ImageViewerImageViewController()
        imageViewController.setImage(image)
        imageViewController.delegate = self
        return imageViewController
    }
    
    func setCurrentlyDisplayedViewController(_ viewController: ImageViewerImageViewController?, animated: Bool) {
        guard let viewController = viewController else {
            return
        }
        
        pageViewController.setViewControllers([viewController], direction: .forward, animated: animated, completion: nil)
    }
}

// MARK:- UIPageViewControllerDataSource

extension ImageViewer: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let pageIndex = pageForImageViewController(viewController) {
            return newImageViewController(withImage: imageForPage(pageIndex - 1))
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let pageIndex = pageForImageViewController(viewController) {
            return newImageViewController(withImage: imageForPage(pageIndex + 1))
        }
        return nil
    }
}

// MARK:- UIPageViewControllerDelegate

extension ImageViewer: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        for imageViewController in pendingViewControllers {
            if let imageViewController = imageViewController as? ImageViewerImageViewController {
                imageViewController.resetZoomScaleAnimated(false)
            }
        }
    }
}

// MARK:- ImageViewerImageViewControllerDelegate

extension ImageViewer: ImageViewerImageViewControllerDelegate {
    func imageViewControllerDidSingleTap(_ viewController: ImageViewerImageViewController) {
        setAccessoryViewsHidden(!accessoryViewsHidden, animated: true)
    }
    
    func imageViewControllerDidBeginZooming(_ viewController: ImageViewerImageViewController) {
        setAccessoryViewsHidden(true, animated: true)
    }
    
    func imageViewController(_ viewController: ImageViewerImageViewController, didZoomToScale zoomScale: CGFloat) {
        if zoomScale == 1 {
            setAccessoryViewsHidden(false, animated: true)
        }
    }
}

// MARK:- Instance Methods

extension ImageViewer {
    
    func preparePresentationFromImageView(_ imageView: UIImageView) {
        presentFromView = imageView
        presentationImage = imageView.image
        presentationImageContentMode = imageView.contentMode
    }
    
    func setAccessoryViewsHidden(_ accessoryViewsHidden: Bool, animated: Bool) {
        guard accessoryViewsHidden != self.accessoryViewsHidden else {
            return
        }
        
        self.accessoryViewsHidden = accessoryViewsHidden
        
        func updateAlphas() {
            self.controlsView.alpha = accessoryViewsHidden ? 0.0 : 1.0
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: updateAlphas)
        } else {
            updateAlphas()
        }
    }
}
