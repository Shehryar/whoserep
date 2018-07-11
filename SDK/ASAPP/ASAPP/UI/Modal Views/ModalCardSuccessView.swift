//
//  ModalCardSuccessView.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/11/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

class ModalCardSuccessView: UIView {

    var contentInset = UIEdgeInsets(top: 46, left: 30, bottom: 35, right: 30) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var imageSize: CGFloat = 64
    
    var imageMarginBottom: CGFloat = 25
    
    var font: UIFont = Fonts.default.bold.changingOnlySize(24)
    
    var text: String? {
        didSet {
            updateDisplay()
        }
    }
    
    var primaryColor: UIColor = UIColor(red: 0.192, green: 0.208, blue: 0.247, alpha: 1) {
        didSet {
            updateDisplay()
        }
    }
    
    private let imageView = UIImageView(image: ComponentIcon.getImage(.navCheck))
    private let label = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        updateDisplay()
        
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        label.numberOfLines = 1
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.clipsToBounds = true
        addSubview(label)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Display
    
    func updateDisplay() {
        if let text = text {
            label.attributedText = NSAttributedString(string: text, attributes: [
                .font: font,
                .foregroundColor: primaryColor,
                .kern: 1
            ])
        } else {
            label.attributedText = nil
        }
        
        setNeedsLayout()
    }

    // MARK: Layout
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        let imageLeft = floor((size.width - imageSize) / 2.0)
        let imageFrame = CGRect(x: imageLeft, y: contentInset.top, width: imageSize, height: imageSize)
        
        let labelWidth = size.width - contentInset.left - contentInset.right
        let labelHeight = ceil(label.sizeThatFits(CGSize(width: labelWidth, height: 0)).height)
        var labelTop = imageFrame.maxY
        if labelHeight > 0 {
            labelTop += imageMarginBottom
        }
        let labelFrame = CGRect(x: contentInset.left, y: labelTop, width: labelWidth, height: labelHeight)
        
        return (imageFrame, labelFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (imageFrame, labelFrame) = getFramesThatFit(bounds.size)
        imageView.frame = imageFrame
        label.frame = labelFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (_, labelFrame) = getFramesThatFit(bounds.size)
        let height = labelFrame.maxY + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}
