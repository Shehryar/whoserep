//
//  ImageViewerImageView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ImageViewerImageView: UIView {

    var image: UIImage? {
        set {
            imageURL = nil
            spinner.stopAnimating()
            _setImage(newValue)
        }
        get { return imageView.image }
    }
    
    var showsSpinnerWhileLoading = true {
        didSet {
            if !showsSpinnerWhileLoading && spinner.isAnimating {
                spinner.stopAnimating()
            }
        }
    }
    
    private(set) var imageURL: URL?
    
    private let imageView = UIImageView()
    
    private let spinner = UIActivityIndicatorView()
    
    // MARK: Init
    
    func commonInit() {
        spinner.activityIndicatorViewStyle = .white
        spinner.hidesWhenStopped = true
        addSubview(spinner)
        
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        spinner.center = CGPoint(x: bounds.midX, y: bounds.midY)
        updateImageViewFrame()
    }
    
    func updateImageViewFrame() {
        guard let image = image else {
            return
        }
        
        let boundsHeight = bounds.height
        let boundsWidth = bounds.width
        
        var imageFrame: CGRect
        switch contentMode {
        case .scaleAspectFill:
            // Image frame width/height must be >= view frame width/height
            var scaledSize = self .aspectScaleSize(image.size, toHeight: boundsHeight)
            if scaledSize.width < boundsWidth || scaledSize.height < boundsHeight {
                scaledSize = aspectScaleSize(image.size, toWidth: boundsWidth)
            }
            imageFrame = createFrame(withSize: scaledSize, centeredInFrame: bounds)
            break
            
        case .center:
            imageFrame = createFrame(withSize: image.size, centeredInFrame: bounds)
            break
            
        default: // case .ScaleAspectFit:
            var scaledSize = aspectScaleSize(image.size, toHeight: boundsHeight)
            if scaledSize.width > boundsWidth || scaledSize.height > boundsHeight {
                scaledSize = aspectScaleSize(image.size, toWidth: boundsWidth)
            }
            imageFrame = createFrame(withSize: scaledSize, centeredInFrame: bounds)
            break
        }
        
        imageView.frame = imageFrame
    }
}

// MARK: - Utility

extension ImageViewerImageView {
    
    func aspectScaleSize(_ size: CGSize, toWidth scaleToWidth: CGFloat) -> CGSize {
        if size.width.isZero {
            return CGSize(width: scaleToWidth, height: 0)
        }
        
        let scaledHeight = scaleToWidth * size.height / size.width
        return CGSize(width: scaleToWidth, height: scaledHeight)
    }
    
    func aspectScaleSize(_ size: CGSize, toHeight scaleToHeight: CGFloat) -> CGSize {
        if size.height.isZero {
            return CGSize(width: 0, height: scaleToHeight)
        }
        
        let scaledWidth = scaleToHeight * size.width / size.height
        return CGSize(width: scaledWidth, height: scaleToHeight)
    }
    
    func createFrame(withSize size: CGSize, centeredInFrame centerInFrame: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: (centerInFrame.width - size.width) / 2.0,
                                      y: (centerInFrame.height - size.height) / 2.0),
                      size: size)
    }
}

// MARK: - Instance Methods

typealias ImageViewImageDownloadCompletion = ((_ image: UIImage?, _ imageURL: URL, _ error: Error?) -> Void)

extension ImageViewerImageView {
    private func _setImage(_ image: UIImage?) {
        imageView.image = image
        updateImageViewFrame()
    }
    
    func setImageWithURL(_ imageURL: URL, placeholderImage: UIImage? = nil, completion: ImageViewImageDownloadCompletion? = nil) {
        
        self.imageURL = imageURL
        if self.imageURL == nil {
            _setImage(image)
            return
        }
        
        if showsSpinnerWhileLoading {
            spinner.startAnimating()
        }
        
        imageView.sd_setImage(with: imageURL, placeholderImage: placeholderImage, options: SDWebImageOptions(rawValue: UInt(0)), completed: { [weak self] (downloadedImage, downloadError, _, downloadedImageURL) in
            
            if let downloadedImageURL = downloadedImageURL {
                if downloadedImageURL == self?.imageURL {
                    self?.spinner.stopAnimating()
                    self?._setImage(downloadedImage)
                    
                    completion?(downloadedImage, downloadedImageURL, downloadError)
                }
            }
        })
    }
    
    func setFrame(_ frame: CGRect, contentMode: UIViewContentMode) {
        if !frame.equalTo(self.frame) || contentMode != self.contentMode {
            super.frame = frame
            super.contentMode = contentMode
            self.updateImageViewFrame()
        }
    }
}
