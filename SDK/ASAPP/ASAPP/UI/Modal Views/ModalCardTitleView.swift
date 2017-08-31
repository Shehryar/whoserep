//
//  ModalCardTitleView.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/13/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

class ModalCardTitleView: UIView {

    var text: String? {
        didSet {
            updateText()
        }
    }
    
    var image: UIImage? {
        didSet {
            updateImageView()
        }
    }
    
    let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let imageWidth: CGFloat = 28
    let imageMargin: CGFloat = 10
    let font = Fonts.latoBoldFont(withSize: 18)
    let textColor = UIColor(red: 0.263, green: 0.278, blue: 0.318, alpha: 1)
    
    fileprivate let label = UILabel()
    fileprivate let imageView = UIImageView()
    
    // MARK: Initialization
    
    func commonInit() {
        label.font = font
        label.textColor = textColor
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        addSubview(label)
        
        updateText()
        
        imageView.contentMode = .scaleAspectFit
        updateImageView()
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
        
        let (labelFrame, imageFrame) = getFrames(for: bounds.size)
        label.frame = labelFrame
        imageView.frame = imageFrame
    }
    
    func getFrames(for size: CGSize) -> (CGRect, CGRect) {
        let maxTextWidth = size.width - contentInset.right - contentInset.left - imageWidth - imageMargin
        let textHeight = ceil(label.sizeThatFits(CGSize(width: maxTextWidth, height: 0)).height)
        
        var imageHeight: CGFloat = 0.0
        if let image = imageView.image {
            if image.size.width > 0 {
                imageHeight = ceil(imageWidth * image.size.height / image.size.width)
            }
        }
        
        let totalHeight = (contentInset.top + max(imageHeight, textHeight) + contentInset.bottom)
        let textTop = floor((totalHeight - textHeight) / 2.0)
        let textFrame = CGRect(x: contentInset.left, y: textTop, width: maxTextWidth, height: textHeight)
        
        let imageTop = floor((totalHeight - imageHeight) / 2.0)
        let imageLeft = size.width - contentInset.right - imageWidth
        let imageFrame = CGRect(x: imageLeft, y: imageTop, width: imageWidth, height: imageHeight)
        
        return (textFrame, imageFrame)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (labelFrame, imageFrame) = getFrames(for: size)
        let height = contentInset.top + max(imageFrame.height, labelFrame.height) + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
    
    // MARK: Image
    
    func updateText() {
        label.setAttributedText(text, textType: .header2, color: textColor)
        setNeedsLayout()
    }
    
    func updateImageView() {
        if let image = image {
            imageView.image = image.tinted(UIColor(red: 0.549, green: 0.557, blue: 0.576, alpha: 1))
        } else {
            imageView.image = nil
        }
    }
}
