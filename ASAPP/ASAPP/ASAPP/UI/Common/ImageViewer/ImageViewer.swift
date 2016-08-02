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
    
    var presentationImageContentMode: UIViewContentMode = .ScaleAspectFill
    
    // MARK: Properties: Readonly
    
    private(set) var images: [ImageViewerImage]
    
    private(set) var initialIndex: Int
    
    var currentImage: ImageViewerImage? {
        return currentImageViewController()?.image
    }
    
    var currentlyDisplayedImage: UIImage? {
        return currentImageViewController()?.imageView.image
    }
    
    var currentIndex: Int {
        if let currentImage = currentImage {
            return images.indexOf(currentImage) ?? 0
        }
        return 0
    }
    
    private(set) var accessoryViewsHidden = false
    
    // MARK: Properties: Private
    
    private var viewAppeared = false
    
    private var transitionAnimator = ImageViewerTransitionAnimator()
    
    private let controlsView = ImageViewerControlsView()
    
    private let pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 10])
    
    // MARK: Initialization
    
    required init(withImages images: [ImageViewerImage], initialIndex: Int = 0) {
        self.images = images
        self.initialIndex = initialIndex
        if self.initialIndex >= self.images.count {
            self.initialIndex = 0
        }
        
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false
        modalPresentationStyle = .Custom
        modalTransitionStyle = .CrossDissolve
        modalPresentationCapturesStatusBarAppearance = true
        transitioningDelegate = transitionAnimator
        
        controlsView.onDismissButtonTap = {
            self.dismissViewControllerAnimated(true, completion: nil)
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

        view.backgroundColor = UIColor.clearColor()
        
        view.addSubview(pageViewController.view)
        view.addSubview(controlsView)
        
        if let initialImage = imageForPage(initialIndex) {
            if let initialViewController = newImageViewController(withImage: initialImage) {
                initialViewController.setImage(initialImage, placeholderImage: presentationImage)
                setCurrentlyDisplayedViewController(initialViewController, animated: false)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !viewAppeared {
            viewAppeared = true
            UIView.animateWithDuration(0.3, animations: { 
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
        
    }
    
    // MARK: Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        controlsView.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(view.bounds), height: 50)
        pageViewController.view.frame = view.bounds
    }
}

// MARK:- UIStatusBar

extension ImageViewer {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if viewAppeared {
            return true
        }
        return super.prefersStatusBarHidden()
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
}

// MARK:- Content Utilities

extension ImageViewer {
    func imageForPage(page: Int) -> ImageViewerImage? {
        if page >= 0 && page < images.count {
            return images[page]
        }
        return nil
    }
    
    func pageForImageViewController(imageViewController: UIViewController?) -> Int? {
        guard let imageViewController = imageViewController as? ImageViewerImageViewController else {
            return nil
        }
        
        if let imageViewControllerImage = imageViewController.image {
            return self.images.indexOf(imageViewControllerImage)
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
    
    func setCurrentlyDisplayedViewController(viewController: ImageViewerImageViewController?, animated: Bool) {
        guard let viewController = viewController else {
            return
        }
        
        pageViewController.setViewControllers([viewController], direction: .Forward, animated: animated, completion: nil)
    }
}

// MARK:- UIPageViewControllerDataSource

extension ImageViewer: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let pageIndex = pageForImageViewController(viewController) {
            return newImageViewController(withImage: imageForPage(pageIndex - 1))
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let pageIndex = pageForImageViewController(viewController) {
            return newImageViewController(withImage: imageForPage(pageIndex + 1))
        }
        return nil
    }
}

// MARK:- UIPageViewControllerDelegate

extension ImageViewer: UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        for imageViewController in pendingViewControllers {
            if let imageViewController = imageViewController as? ImageViewerImageViewController {
                imageViewController.resetZoomScaleAnimated(false)
            }
        }
    }
}

// MARK:- ImageViewerImageViewControllerDelegate

extension ImageViewer: ImageViewerImageViewControllerDelegate {
    func imageViewControllerDidSingleTap(viewController: ImageViewerImageViewController) {
        setAccessoryViewsHidden(!accessoryViewsHidden, animated: true)
    }
    
    func imageViewControllerDidBeginZooming(viewController: ImageViewerImageViewController) {
        setAccessoryViewsHidden(true, animated: true)
    }
    
    func imageViewController(viewController: ImageViewerImageViewController, didZoomToScale zoomScale: CGFloat) {
        if zoomScale == 1 {
            setAccessoryViewsHidden(false, animated: true)
        }
    }
}

// MARK:- Instance Methods

extension ImageViewer {
    
    func preparePresentationFromImageView(imageView: UIImageView) {
        presentFromView = imageView
        presentationImage = imageView.image
        presentationImageContentMode = imageView.contentMode
    }
    
    func setAccessoryViewsHidden(accessoryViewsHidden: Bool, animated: Bool) {
        guard accessoryViewsHidden != self.accessoryViewsHidden else {
            return
        }
        
        self.accessoryViewsHidden = accessoryViewsHidden
        
        func updateAlphas() {
            self.controlsView.alpha = accessoryViewsHidden ? 0.0 : 1.0
        }
        
        if animated {
            UIView.animateWithDuration(0.3, animations: updateAlphas)
        } else {
            updateAlphas()
        }
    }
}
