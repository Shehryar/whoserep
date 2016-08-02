//
//  ImageViewerImageViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ImageViewerImageViewControllerDelegate {
    func imageViewControllerDidSingleTap(viewController: ImageViewerImageViewController)
    func imageViewControllerDidBeginZooming(viewController: ImageViewerImageViewController)
    func imageViewController(viewController: ImageViewerImageViewController, didZoomToScale zoomScale: CGFloat)
}

class ImageViewerImageViewController: UIViewController {

    // MARK: Properties
    
    private(set) var image: ImageViewerImage?
    
    var zoomScale: CGFloat {
        return scrollView.zoomScale
    }
    
    let imageView = ImageViewerImageView()
    
    var delegate: ImageViewerImageViewControllerDelegate?
    
    // MARK: Private Properties
    
    private let scrollView = UIScrollView()
    
    private var zoomEnabled: Bool {
        return imageView.image != nil
    }
    
    // MARK: Init
    
    func commonInit() {
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        
        imageView.contentMode = .ScaleAspectFit
        scrollView.addSubview(imageView)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewerImageViewController.didDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewerImageViewController.didSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.requireGestureRecognizerToFail(doubleTap)
        scrollView.addGestureRecognizer(singleTap)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        scrollView.delegate = nil
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        imageView.frame = scrollView.bounds
    }
}

// MARK:- UIScrollViewDelegate

extension ImageViewerImageViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if zoomEnabled {
            return imageView
        }
        return nil
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        delegate?.imageViewControllerDidBeginZooming(self)
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        delegate?.imageViewController(self, didZoomToScale: scale)
    }
}

// MARK:- Zoom

extension ImageViewerImageViewController {
    func createZoomRect(forScale scale: CGFloat, withCenter zoomCenter: CGPoint) -> CGRect {
        var zoomRect = CGRectZero
        zoomRect.size.width = CGRectGetWidth(scrollView.bounds) / scale
        zoomRect.size.height = CGRectGetHeight(scrollView.bounds) / scale
        zoomRect.origin.x = zoomCenter.x - CGRectGetWidth(zoomRect) / 2.0
        zoomRect.origin.y = zoomCenter.y - CGRectGetHeight(zoomRect) / 2.0
        return zoomRect
    }
}

// MARK:- Actions

extension ImageViewerImageViewController {
    func didDoubleTap(tapGesture: UITapGestureRecognizer) {
        guard zoomEnabled else { return }
        
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let point = tapGesture.locationInView(tapGesture.view)
            let zoomRect = createZoomRect(forScale: 2.0, withCenter: point)
            scrollView.zoomToRect(zoomRect, animated: true)
        }
    }
    
    func didSingleTap(tapGesture: UITapGestureRecognizer) {
        if scrollView.zoomScale != 1 {
            resetZoomScaleAnimated(true)
        } else {
            delegate?.imageViewControllerDidSingleTap(self)
        }
    }
}

// MARK:- Instance Methods

extension ImageViewerImageViewController {
    func setImage(image: ImageViewerImage?, placeholderImage: UIImage? = nil) {
        self.image = image
        
        imageView.image = nil
        resetZoomScaleAnimated(false)
        
        if let imageObject = image?.image {
            imageView.image = imageObject
        } else if let imageURL = image?.imageURL {
            imageView.setImageWithURL(imageURL, placeholderImage: placeholderImage)
        }
    }
    
    func resetZoomScaleAnimated(animated: Bool) {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: animated)
    }
}
