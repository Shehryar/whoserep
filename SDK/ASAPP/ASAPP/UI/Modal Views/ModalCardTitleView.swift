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
    
    let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let font = ASAPP.styles.textStyles.header2.font
    let textColor = UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 1)
    
    fileprivate let label = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        label.font = font
        label.textColor = textColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        addSubview(label)
        
        updateText()
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
        
        label.frame = getFrame(for: bounds.size)
    }
    
    func getFrame(for size: CGSize) -> CGRect {
        let maxTextWidth = size.width - contentInset.right - contentInset.left
        let textHeight = ceil(label.sizeThatFits(CGSize(width: maxTextWidth, height: 0)).height)
        
        let totalHeight = contentInset.top + textHeight + contentInset.bottom
        let textTop = floor((totalHeight - textHeight) / 2.0)
        let textFrame = CGRect(x: contentInset.left, y: textTop, width: maxTextWidth, height: textHeight)
        
        return textFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelFrame = getFrame(for: size)
        let height = contentInset.top + labelFrame.height + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
    
    // MARK: Image
    
    func updateText() {
        label.setAttributedText(text, textType: .header2, color: textColor)
        setNeedsLayout()
    }
}
