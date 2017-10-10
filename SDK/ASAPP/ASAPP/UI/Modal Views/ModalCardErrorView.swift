//
//  ModalCardErrorView.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/13/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

class ModalCardErrorView: UIView {

    var text: String? {
        didSet {
            label.text = text
            if label.text == nil || label.text!.isEmpty {
                imageView.alpha = 0.0
            } else {
                imageView.alpha = 1.0
            }
            setNeedsLayout()
        }
    }
    
    let contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    let imageMargin: CGFloat = 16.0
    let imageSize: CGFloat = 16.0
    let font: UIFont = Fonts.default.bold.withSize(12)
    
    private let imageView = UIImageView(image: Images.asappImage(.iconErrorAlert)?.tinted(UIColor.white))
    private let label = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = UIColor(red: 0.945, green: 0.459, blue: 0.388, alpha: 1)
        clipsToBounds = true
        
        label.font = font
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.clipsToBounds = true
        addSubview(label)
        
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
        
        let (imageFrame, labelFrame) = getFrames(for: bounds.size)
        imageView.frame = imageFrame
        label.frame = labelFrame
    }
    
    func getFrames(for size: CGSize) -> (CGRect, CGRect) {
        let maxTextWidth = size.width - contentInset.right - contentInset.left - imageSize - imageMargin
        var textSize = label.sizeThatFits(CGSize(width: maxTextWidth, height: 0))
        textSize.width = ceil(textSize.width)
        textSize.height = ceil(textSize.height)
        
        let contentWidth = imageSize + imageMargin + textSize.width
        
        let imageLeft = floor((size.width - contentWidth) / 2.0)
        var imageTop = contentInset.top
        if textSize.height > imageSize {
            imageTop = contentInset.top + floor((textSize.height - imageSize) / 2.0)
        }
        let imageFrame = CGRect(x: imageLeft, y: imageTop, width: imageSize, height: imageSize)
        
        let textLeft = imageFrame.maxX + imageMargin
        var textTop = contentInset.top
        if imageSize > textSize.height {
            textTop = contentInset.top + floor((imageSize - textSize.height) / 2.0)
        }
        let textFrame = CGRect(x: textLeft, y: textTop, width: textSize.width, height: textSize.height)
        
        return (imageFrame, textFrame)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (imageFrame, labelFrame) = getFrames(for: size)
        let height = max(imageFrame.maxY, labelFrame.maxY) + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}
