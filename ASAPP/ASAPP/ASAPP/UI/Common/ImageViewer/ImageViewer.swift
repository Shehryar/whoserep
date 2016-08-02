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
    
    var currentImage: ImageViewerImage {
        return ImageViewerImage()
    }
    
    var currentlyDisplayedImage: UIImage? 
    
    private(set) var currentIndex: Int = 0
    
    private(set) var accessoryViewsHidden = false
    
    // MARK: Properties: Private
    
    private var transitionAnimator = ImageViewerTransitionAnimator()
    
    // MARK: Initialization
    
    required init(withImages images: [ImageViewerImage], initialIndex: Int = 0) {
        self.images = images
        self.initialIndex = initialIndex
        
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false
        modalPresentationStyle = .Custom
        modalTransitionStyle = .CrossDissolve
        modalPresentationCapturesStatusBarAppearance = true
        transitioningDelegate = transitionAnimator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

// MARK:- Instance Methods

extension ImageViewer {
    
    func preparePresentationFromImageView(imageView: UIImageView) {
        
    }
    
    func setAccessoryViewsHidden(accessoryViewsHidden: Bool, animated: Bool) {
        
    }
}
