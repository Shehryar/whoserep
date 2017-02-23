//
//  StarView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class StarView: UIView {

    var isFilled: Bool = false {
        didSet {
            if isFilled != oldValue {
                updateImage()
            }
        }
    }
    
    var defaultTintColor: UIColor = UIColor(red:0.243, green:0.635, blue:0.851, alpha:1.000) {
        didSet {
            updateImage()
        }
    }
    
    var filledTintColor: UIColor = UIColor(red:0.243, green:0.635, blue:0.851, alpha:1.000) {
        didSet {
            updateImage()
        }
    }
    
    let imageView = UIImageView()
    
    // MARK: Initialization
    
    func commonInit() {
        clipsToBounds = false
        
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        updateImage()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Image

    func updateImage() {
        let updatedImage: UIImage?
        if isFilled {
            updatedImage = Images.asappImage(.iconStarFilled)?.tinted(filledTintColor)
        } else {
            updatedImage = Images.asappImage(.iconStar)?.tinted(defaultTintColor)
        }
        imageView.image = updatedImage
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    func updateFrames() {
        if imageView.transform.isIdentity {
            imageView.frame = bounds
        }
    }
}
