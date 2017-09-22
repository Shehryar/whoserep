//
//  ImageViewerImageViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ImageViewerImageViewControllerDelegate: class {
    func imageViewControllerDidSingleTap(_ viewController: ImageViewerImageViewController)
    func imageViewControllerDidBeginZooming(_ viewController: ImageViewerImageViewController)
    func imageViewController(_ viewController: ImageViewerImageViewController, didZoomToScale zoomScale: CGFloat)
}

class ImageViewerImageViewController: UIViewController {

    // MARK: Properties
    
    fileprivate(set) var image: ImageViewerImage?
    
    var zoomScale: CGFloat {
        return scrollView.zoomScale
    }
    
    let imageView = ImageViewerImageView()
    
    weak var delegate: ImageViewerImageViewControllerDelegate?
    
    // MARK: Private Properties
    
    fileprivate let scrollView = UIScrollView()
    
    fileprivate var zoomEnabled: Bool {
        return imageView.image != nil
    }
    
    // MARK: Init
    
    func commonInit() {
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewerImageViewController.didDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewerImageViewController.didSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        scrollView.addGestureRecognizer(singleTap)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if zoomEnabled {
            return imageView
        }
        return nil
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.imageViewControllerDidBeginZooming(self)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegate?.imageViewController(self, didZoomToScale: scale)
    }
}

// MARK:- Zoom

extension ImageViewerImageViewController {
    func createZoomRect(forScale scale: CGFloat, withCenter zoomCenter: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.width = scrollView.bounds.width / scale
        zoomRect.size.height = scrollView.bounds.height / scale
        zoomRect.origin.x = zoomCenter.x - zoomRect.width / 2.0
        zoomRect.origin.y = zoomCenter.y - zoomRect.height / 2.0
        return zoomRect
    }
}

// MARK:- Actions

extension ImageViewerImageViewController {
    @objc func didDoubleTap(_ tapGesture: UITapGestureRecognizer) {
        guard zoomEnabled else { return }
        
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let point = tapGesture.location(in: tapGesture.view)
            let zoomRect = createZoomRect(forScale: 2.0, withCenter: point)
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    @objc func didSingleTap(_ tapGesture: UITapGestureRecognizer) {
        if scrollView.zoomScale != 1 {
            resetZoomScaleAnimated(true)
        } else {
            delegate?.imageViewControllerDidSingleTap(self)
        }
    }
}

// MARK:- Instance Methods

extension ImageViewerImageViewController {
    func setImage(_ image: ImageViewerImage?, placeholderImage: UIImage? = nil) {
        self.image = image
        
        imageView.image = nil
        resetZoomScaleAnimated(false)
        
        if let imageObject = image?.image {
            imageView.image = imageObject
        } else if let imageURL = image?.imageURL {
            imageView.setImageWithURL(imageURL, placeholderImage: placeholderImage)
        }
    }
    
    func resetZoomScaleAnimated(_ animated: Bool) {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: animated)
    }
}
