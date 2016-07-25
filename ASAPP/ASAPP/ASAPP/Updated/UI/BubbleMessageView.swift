//
//  BubbleMessageView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class BubbleMessageView: UIView {

    // MARK: Public Properties
    
    public var message: String? {
        didSet {
            textLabel.text = message
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    public var isReply: Bool = false {
        didSet {
            if isReply {
                bubbleView.hardCorner = .BottomLeft
            } else {
                bubbleView.hardCorner = .BottomRight
            }
        }
    }
    
    public var contentInset = UIEdgeInsetsMake(10, 16, 10, 16) {
        didSet {
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
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
        textLabel.textColor = UIColor.darkTextColor()
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
    
    // MARK: Layout
    
    override func updateConstraints() {
        bubbleView.snp_remakeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        textLabel.snp_updateConstraints { (make) in
            make.left.equalTo(self.snp_left).offset(contentInset.left)
            make.top.equalTo(self.snp_top).offset(contentInset.top)
            make.right.lessThanOrEqualTo(self.snp_right).offset(-contentInset.right)
        }
        
        self.snp_updateConstraints { (make) in
           make.height.greaterThanOrEqualTo(textLabel.snp_height).offset(contentInset.top + contentInset.bottom)
        }

        super.updateConstraints()
    }
}
