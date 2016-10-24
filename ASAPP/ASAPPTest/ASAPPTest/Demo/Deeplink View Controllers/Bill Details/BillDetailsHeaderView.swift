//
//  BillDetailsHeaderView.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/24/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

struct BillOverview {
    let balance: String
    let billingPeriod: String
}

class BillDetailsHeaderView: UIView {

    var contentInset = UIEdgeInsets(top: 30, left: 16, bottom: 30, right: 16) {
        didSet {
            setNeedsLayout()
        }
    }
    
    fileprivate let billingPeriodLabel = UILabel()
    
    fileprivate let balanceLabel = UILabel()
    
    fileprivate let detailLabel = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = UIColor.white
        
        billingPeriodLabel.font = DemoFonts.avenirHeavy(14)
        billingPeriodLabel.textColor = UIColor.lightGray
        billingPeriodLabel.textAlignment = .center
        addSubview(billingPeriodLabel)
        
        balanceLabel.font = DemoFonts.avenirBlack(28)
        balanceLabel.textColor = UIColor.darkText
        balanceLabel.textAlignment = .center
        balanceLabel.numberOfLines = 0
        balanceLabel.lineBreakMode = .byTruncatingTail
        addSubview(balanceLabel)
        
        detailLabel.text = "TOTAL BALANCE"
        detailLabel.textColor = UIColor.lightGray
        detailLabel.textAlignment = .center
        detailLabel.font = DemoFonts.avenirHeavy(14)
        detailLabel.numberOfLines = 0
        detailLabel.lineBreakMode = .byTruncatingTail
        addSubview(detailLabel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK:- Layout
    
    func getLabelFrames(forSize size: CGSize) -> (CGRect, CGRect, CGRect) {
        let contentWidth = size.width - contentInset.left - contentInset.right
        let left = contentInset.left
        let sizer = CGSize(width: contentWidth, height: 0)
        
        let billingPeriodHeight = ceil(billingPeriodLabel.sizeThatFits(sizer).height)
        let balanceHeight = ceil(balanceLabel.sizeThatFits(sizer).height)
        let detailHeight = ceil(detailLabel.sizeThatFits(sizer).height)
        
        let billingPeriodTop = contentInset.top
        let billingPeriodFrame = CGRect(x: left, y: billingPeriodTop, width: contentWidth, height: billingPeriodHeight)
        
        let balanceTop = billingPeriodFrame.maxY + 10
        let balanceFrame = CGRect(x: left, y: balanceTop, width: contentWidth, height: balanceHeight)
        
        let detailTop = balanceFrame.maxY
        let detailFrame = CGRect(x: left, y: detailTop, width: contentWidth, height: detailHeight)
        
        return (billingPeriodFrame, balanceFrame, detailFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (billingPeriodFrame, balanceFrame, detailFrame) = getLabelFrames(forSize: bounds.size)
        billingPeriodLabel.frame = billingPeriodFrame
        balanceLabel.frame = balanceFrame
        detailLabel.frame = detailFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (billingPeriodFrame, balanceFrame, detailFrame) = getLabelFrames(forSize: size)
        var maxY: CGFloat = 0
        for frame in [billingPeriodFrame, balanceFrame, detailFrame] {
            maxY = max(maxY, frame.maxY)
        }
        let height: CGFloat = maxY + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}

// MARK:- Public Instance Methods

extension BillDetailsHeaderView {
    
    func update(billOverview: BillOverview?) {
        balanceLabel.text = billOverview?.balance
        billingPeriodLabel.text = billOverview?.billingPeriod
        
        setNeedsLayout()
    }
}
