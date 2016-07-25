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
        didSet {
            textLabel.text = message
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    var isReply: Bool = false {
        didSet {
            if oldValue != isReply {
                updateMessageViewForIsReply()
                
                setNeedsUpdateConstraints()
                updateConstraintsIfNeeded()
            }
        }
    }
    
    var contentInset = UIEdgeInsetsMake(10, 16, 10, 16) {
        didSet {
            if oldValue != contentInset {
                setNeedsUpdateConstraints()
                updateConstraintsIfNeeded()
            }
        }
    }
    
    // MARK: Private Properties
    
    private let textLabel = UILabel()
    
    private let bubbleView = BubbleView()
    
    private var leftConstraint: Constraint?
    
    private var rightConstraint: Constraint?
    
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
        
        updateMessageViewForIsReply()
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
    
    // MARK: Layout
    
    func updateMessageViewForIsReply() {
        if isReply {
            bubbleView.hardCorner = .BottomLeft
            bubbleView.fillColor = Colors.bluishGray()
            textLabel.textColor = UIColor.whiteColor()
        } else {
            bubbleView.hardCorner = .BottomRight
            bubbleView.fillColor = Colors.lightGrayColor()
            textLabel.textColor = Colors.darkTextColor()
        }
    }
    
    override func updateConstraints() {
        leftConstraint?.uninstall()
        rightConstraint?.uninstall()
        
        textLabel.snp_updateConstraints { (make) in
            make.top.equalTo(self.snp_top).offset(contentInset.top)
            if isReply {
                self.leftConstraint = make.left.equalTo(self.snp_left).offset(contentInset.left).constraint
            } else {
                self.rightConstraint = make.right.equalTo(self.snp_right).offset(-contentInset.right).constraint
            }
            make.width.lessThanOrEqualTo(self.snp_width).offset(-(contentInset.left + contentInset.right))
        }
        
        bubbleView.snp_updateConstraints { (make) in
            make.top.equalTo(self.snp_top)
            make.left.equalTo(textLabel.snp_left).offset(-contentInset.left)
            make.right.equalTo(textLabel.snp_right).offset(contentInset.right)
            make.height.equalTo(textLabel.snp_height).offset(contentInset.top + contentInset.bottom)
        }
        
        self.snp_updateConstraints { (make) in
           make.height.greaterThanOrEqualTo(textLabel.snp_height).offset(contentInset.top + contentInset.bottom)
        }

        super.updateConstraints()
    }
}
