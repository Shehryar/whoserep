//
//  ActivityTableViewCell.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 6/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    
    var holder: UIView!
    
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    
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
        
        titleLabel = UILabel()
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "Lato-Bold", size: 16)
        holder.addSubview(titleLabel)
        
        descriptionLabel = UILabel()
        descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont(name: "Lato-Regular", size: 16)
        holder.addSubview(descriptionLabel)
    }
    
    func updateActivity(activity: TimelineModel.CCActivity) {
        updateTitle(activity.Title)
        updateDescription(activity.Description)
        
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
    
    func updateDescription(text: String) {
        let descriptionColor = UIColor(red: 57/255, green: 61/255, blue: 71/255, alpha: 0.4)
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: 1, range: NSMakeRange(0, text.characters.count))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: descriptionColor, range: NSMakeRange(0, text.characters.count))
        
        descriptionLabel.attributedText = attributedString
    }
    
    override func updateConstraints() {
        holder.snp_remakeConstraints { (make) in
            make.top.equalTo(self.contentView.snp_top).offset(5)
            make.leading.equalTo(self.contentView.snp_leading).offset(10)
            make.trailing.equalTo(self.contentView.snp_trailing).offset(-10)
            make.bottom.equalTo(self.contentView.snp_bottom).offset(-5)
        }
        
        titleLabel.snp_remakeConstraints { (make) in
            make.top.equalTo(holder.snp_top).offset(20)
            make.leading.equalTo(holder.snp_leading).offset(20)
            make.trailing.equalTo(holder.snp_trailing).offset(-20)
        }
        
        descriptionLabel.snp_remakeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(10)
            make.leading.equalTo(titleLabel.snp_leading)
            make.trailing.equalTo(titleLabel.snp_trailing)
            make.bottom.equalTo(holder.snp_bottom).offset(-20).priorityMedium()
        }
        
        super.updateConstraints()
    }
}
