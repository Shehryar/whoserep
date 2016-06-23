//
//  JourneyTableViewCell.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 6/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class JourneyTableViewCell: UITableViewCell {

    var holder: UIView!
    var borderView: UIView!
    
    var titleLabel: UILabel!
    var itemHolder: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render() {
        self.backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        holder = UIView()
        holder.backgroundColor = UIColor.whiteColor()
        holder.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).CGColor
        holder.layer.borderWidth = 1
        self.contentView.addSubview(holder)
        
        borderView = UIView()
        borderView.backgroundColor = UIColor(red: 237/255, green: 102/255, blue: 85/255, alpha: 1)
        holder.addSubview(borderView)
        
        titleLabel = UILabel()
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "Lato-Bold", size: 16)
        holder.addSubview(titleLabel)
        
        itemHolder = UIView()
        holder.addSubview(itemHolder)
    }
    
    func updateJourney(journey: TimelineModel.CCJourney) {
        updateTitle(journey.Title)
        
        itemHolder.subviews.forEach({ $0.removeFromSuperview() })
        addJourneyItem(journey.Items)
        
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }
    
    func updateTitle(text: String) {
        let titleColor = UIColor(red: 57/255, green: 61/255, blue: 71/255, alpha: 1)
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: 1, range: NSMakeRange(0, text.characters.count))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: titleColor, range: NSMakeRange(0, text.characters.count))
        
        titleLabel.attributedText = attributedString
    }
    
    func addJourneyItem(items: [TimelineModel.CCJourneyItem]) {
        var prevItemView: UIView? = nil
        for item in items {
            let text = item.key + " " + item.value
            
            let itemKey = UILabel()
            itemKey.lineBreakMode = NSLineBreakMode.ByWordWrapping
            itemKey.numberOfLines = 0
            
            let keyFont = UIFont(name: "Lato-Light", size: 14)
            let valueFont = UIFont(name: "Lato-Bold", size: 14)
            let itemColor = UIColor(red: 108/255, green: 116/255, blue: 128/255, alpha: 1)
            
            let attributedKeyString = NSMutableAttributedString(string: text)
            
            attributedKeyString.addAttribute(NSFontAttributeName, value: keyFont!, range: NSMakeRange(0, item.key.characters.count))
            attributedKeyString.addAttribute(NSFontAttributeName, value: valueFont!, range: NSMakeRange(text.characters.count - item.value.characters.count, item.value.characters.count))
            
            attributedKeyString.addAttribute(NSKernAttributeName, value: 1, range: NSMakeRange(0, text.characters.count))
            attributedKeyString.addAttribute(NSForegroundColorAttributeName, value: itemColor, range: NSMakeRange(0, text.characters.count))
            itemKey.attributedText = attributedKeyString
            
            itemHolder.addSubview(itemKey)
            
            itemKey.snp_makeConstraints(closure: { (make) in
                if prevItemView == nil {
                    make.top.equalTo(itemHolder.snp_top)
                } else {
                    make.top.equalTo((prevItemView?.snp_bottom)!)
                }
                make.leading.equalTo(itemHolder.snp_leading)
                make.trailing.equalTo(itemHolder.snp_trailing)
                make.bottom.lessThanOrEqualTo(itemHolder.snp_bottom)
            })
            
            prevItemView = itemKey
        }
    }
    
    override func updateConstraints() {
        holder.snp_remakeConstraints { (make) in
            make.top.equalTo(self.contentView.snp_top).offset(5)
            make.leading.equalTo(self.contentView.snp_leading).offset(10)
            make.trailing.equalTo(self.contentView.snp_trailing).offset(-10)
            make.bottom.equalTo(self.contentView.snp_bottom).offset(-5)
        }
        
        borderView.snp_remakeConstraints { (make) in
            make.top.equalTo(holder.snp_top)
            make.leading.equalTo(holder.snp_leading)
            make.bottom.equalTo(holder.snp_bottom)
            make.width.equalTo(10)
        }
        
        titleLabel.snp_remakeConstraints { (make) in
            make.top.equalTo(borderView.snp_top).offset(20)
            make.leading.equalTo(borderView.snp_trailing).offset(20)
            make.bottom.lessThanOrEqualTo(borderView.snp_bottom).offset(-20).priorityMedium()
            make.width.equalTo(holder.snp_width).multipliedBy(0.5).offset(-50)
        }
        
        itemHolder.snp_remakeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_top)
            make.leading.equalTo(titleLabel.snp_trailing).offset(20)
            make.trailing.equalTo(holder.snp_trailing).offset(-20)
            make.bottom.lessThanOrEqualTo(borderView.snp_bottom).offset(-20).priorityMedium()
        }
        
        super.updateConstraints()
    }

}
