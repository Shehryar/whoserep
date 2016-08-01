//
//  BubbleMessageView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SnapKit

class BubbleMessageView: UIView {

    // MARK: Public Properties
    
    var message: String? {
        set { textLabel.text = newValue }
        get { return textLabel.text }
    }
    
    var font: UIFont {
        set { textLabel.font = newValue }
        get { return textLabel.font }
    }
    
    var textColor: UIColor? {
        set { textLabel.textColor = newValue }
        get { return textLabel.textColor }
    }
    
    var bubbleViewRoundedCorners: UIRectCorner {
        set { bubbleView.roundedCorners = newValue }
        get { return bubbleView.roundedCorners }
    }
    
    var contentInset = UIEdgeInsetsMake(10, 16, 10, 16) {
        didSet {
            if oldValue != contentInset {
                setNeedsUpdateConstraints()
            }
        }
    }
    
    var bubbleFillColor: UIColor {
        set { bubbleView.fillColor = newValue }
        get { return bubbleView.fillColor }
    }
    
    var bubbleStrokeColor: UIColor? {
        set { bubbleView.strokeColor = newValue }
        get { return bubbleView.strokeColor }
    }
    
    // MARK: Private Properties
    
    private let textLabel = UILabel()
    
    private let bubbleView = BubbleView()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleView)
        
        textLabel.font = Fonts.latoRegularFont(withSize: 16)
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
    }
    
    // MARK: Layout
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var maxLabelSize = size
        maxLabelSize.width -= contentInset.left + contentInset.right
        maxLabelSize.height -= contentInset.top + contentInset.bottom
        
        var fittedLabelSize = textLabel.sizeThatFits(maxLabelSize)
        fittedLabelSize.width = ceil(fittedLabelSize.width + contentInset.left + contentInset.right)
        fittedLabelSize.height = ceil(fittedLabelSize.height + contentInset.top + contentInset.bottom)
        
        return fittedLabelSize
    }
    
    override func updateConstraints() {
        textLabel.snp_updateConstraints { (make) in
            make.top.equalTo(self.snp_top).offset(contentInset.top)
            make.left.equalTo(self.snp_left).offset(contentInset.left)
            make.width.lessThanOrEqualTo(self.snp_width).offset(-(contentInset.left + contentInset.right))
        }
        
        bubbleView.snp_updateConstraints { (make) in
            make.edges.equalTo(self)
            make.height.equalTo(textLabel.snp_height).offset(contentInset.top + contentInset.bottom)
        }
        
        self.snp_updateConstraints { (make) in
           make.height.greaterThanOrEqualTo(textLabel.snp_height).offset(contentInset.top + contentInset.bottom)
        }
        
        super.updateConstraints()
    }
}

// MARK:- Public

extension BubbleMessageView {
    func update() {
        
    }
}
