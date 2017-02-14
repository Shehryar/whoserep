//
//  SuccessCheckmarkView.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/11/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

class SuccessCheckmarkView: UIView {

    var contentInset = UIEdgeInsets(top: 46, left: 30, bottom: 35, right: 30) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var imageSize: CGFloat = 64
    
    var imageMarginBottom: CGFloat = 25
    
    var font: UIFont = Fonts.latoBoldFont(withSize: 24)
    
    var text: String = "New Card Added Successfully!"
    
    var primaryColor: UIColor = UIColor(red:0.192, green:0.208, blue:0.247, alpha:1.000) {
        didSet {
            updateDisplay()
        }
    }
    
    private let imageView = UIImageView(image: Images.imageWithName("icon-circle-checkmark"))
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
        label.attributedText = NSAttributedString(string: text, attributes: [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : primaryColor,
            NSKernAttributeName : 1
            ])
        
        setNeedsLayout()
    }

    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelWidth = bounds.width - contentInset.left - contentInset.right
        let labelHeight = ceil(label.sizeThatFits(CGSize(width: labelWidth, height: 0)).height)
        let contentHeight = imageSize + imageMarginBottom + labelHeight
        
        let imageTop = floor((bounds.height - contentHeight) / 2.0)
        let imageLeft = floor((bounds.width - imageSize) / 2.0)
        imageView.frame = CGRect(x: imageLeft, y: imageTop, width: imageSize, height: imageSize)
        
        let labelTop = imageView.frame.maxY + imageMarginBottom
        label.frame = CGRect(x: contentInset.left, y: labelTop, width: labelWidth, height: labelHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelHeight = ceil(label.sizeThatFits(CGSize(width: size.width - contentInset.left - contentInset.right, height: 0)).height)
        let height = contentInset.top + imageSize + imageMarginBottom + labelHeight + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }
}
