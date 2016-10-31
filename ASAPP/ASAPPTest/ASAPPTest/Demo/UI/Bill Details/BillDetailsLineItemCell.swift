//
//  BillDetailsLineItemCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

struct LineItem {
    let name: String?
    let date: String?
    let amount: String?
}

class BillDetailsLineItemCell: UITableViewCell {

    var contentInset = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24) {
        didSet {
            setNeedsLayout()
        }
    }
    
    fileprivate let nameLabel = UILabel()
    
    fileprivate let dateLabel = UILabel()
    
    fileprivate let amountLabel = UILabel()
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .none
        
        nameLabel.font = DemoFonts.avenirBook(16)
        nameLabel.textColor = UIColor.darkText
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(nameLabel)
        
        dateLabel.font = DemoFonts.avenirMedium(12)
        dateLabel.textColor = UIColor.gray
        dateLabel.numberOfLines = 0
        dateLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(dateLabel)
        
        amountLabel.font = DemoFonts.avenirHeavy(16)
        amountLabel.textColor = UIColor.darkText
        amountLabel.textAlignment = .right
        contentView.addSubview(amountLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    // MARK:- Layout
    
    func getNameDateAmountLabelFrames(forSize size: CGSize) -> (CGRect, CGRect, CGRect) {
        var nameLabelFrame, dateLabelFrame, amountLabelFrame: CGRect
        nameLabelFrame = .zero
        dateLabelFrame = .zero
        amountLabelFrame = .zero
        
        let contentWidth = size.width - contentInset.left - contentInset.right
        let leftWidth = floor(contentWidth * 0.6)
        let leftRightMargin: CGFloat = 10
        let rightWidth = contentWidth - leftWidth - leftRightMargin
        
        let nameHeight = ceil(nameLabel.sizeThatFits(CGSize(width: leftWidth, height: 0)).height)
        nameLabelFrame = CGRect(x: contentInset.left, y: contentInset.top, width: leftWidth, height: nameHeight)
        
        let dateHeight = ceil(dateLabel.sizeThatFits(CGSize(width: leftWidth, height: 0)).height)
        dateLabelFrame = CGRect(x: contentInset.left, y: nameLabelFrame.maxY, width: leftWidth, height: dateHeight)
        
        let amountLeft = size.width - contentInset.right - rightWidth
        let amountHeight = ceil(amountLabel.sizeThatFits(CGSize(width: rightWidth, height: 0)).height)
        amountLabelFrame = CGRect(x: amountLeft, y: contentInset.top, width: rightWidth, height: amountHeight)
        
        return (nameLabelFrame, dateLabelFrame, amountLabelFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (nameLabelFrame, dateLabelFrame, amountLabelFrame) = getNameDateAmountLabelFrames(forSize: bounds.size)
        nameLabel.frame = nameLabelFrame
        dateLabel.frame = dateLabelFrame
        amountLabel.frame = amountLabelFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (nameLabelFrame, dateLabelFrame, amountLabelFrame) = getNameDateAmountLabelFrames(forSize: size)
        var maxY: CGFloat = 0
        for frame in [nameLabelFrame, dateLabelFrame, amountLabelFrame] {
            maxY = max(maxY, frame.maxY)
        }
        let height = maxY + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }
}

// MARK:- Public Instance Methods

extension BillDetailsLineItemCell {
    
    func update(lineItem: LineItem?) {
        nameLabel.text = lineItem?.name
        dateLabel.text = lineItem?.date
        amountLabel.text = lineItem?.amount
        
        setNeedsLayout()
    }
}
