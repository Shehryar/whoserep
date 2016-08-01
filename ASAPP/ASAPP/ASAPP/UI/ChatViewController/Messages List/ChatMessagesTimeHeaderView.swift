//
//  ChatMessagesTimeHeaderView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesTimeHeaderView: UITableViewHeaderFooterView {
    
    var contentInset: UIEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 16)
    
    var timeStampInSeconds: Double = 0.0 {
        didSet { updateTimeLabel() }
    }
    
    private let timeLabel = UILabel()
    
    private let dateFormatter = NSDateFormatter()
    
    // MARK:- Init
    
    func commonInit() {
        timeLabel.font = Fonts.latoBoldFont(withSize: 12)
        timeLabel.textColor = Colors.mediumTextColor()
        timeLabel.textAlignment = .Center
        contentView.addSubview(timeLabel)
        
        setNeedsUpdateConstraints()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK:- Instance Methods
    
    func timeTextForDate(date: NSDate) -> String {
        var dateFormat: String
        if date.isToday() {
            dateFormat = "h:mma"
        } else if date.isYesterday() {
            dateFormat = "'Yesterday at' h:mma"
        } else if date.isThisYear() {
            dateFormat = "MMMM d 'at' h:mma"
        } else {
            dateFormat = "MMMM d, yyyy 'at' h:mma"
        }
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.stringFromDate(date)
    }
    
    func updateTimeLabel() {
        timeLabel.text = timeTextForDate(NSDate(timeIntervalSince1970: timeStampInSeconds ))
    }
    
    // MARK:- Layout
    
    override func updateConstraints() {
        timeLabel.snp_updateConstraints(closure: { (make) in
            make.top.equalTo(contentView.snp_top).offset(contentInset.top)
            make.left.equalTo(contentView.snp_left).offset(contentInset.left)
            make.width.equalTo(contentView.snp_width).offset(-(contentInset.left + contentInset.right))
        })
        
        contentView.snp_updateConstraints { (make) in
            make.width.equalTo(self.snp_width)
            make.height.greaterThanOrEqualTo(timeLabel.snp_height).offset(contentInset.top + contentInset.bottom)
        }
        
        super.updateConstraints()
    }
}
